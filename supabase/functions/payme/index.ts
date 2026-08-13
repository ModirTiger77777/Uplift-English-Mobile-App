import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.7";

const supabase = createClient(
  Deno.env.get("SUPABASE_URL") ?? "",
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""
);

const PAYME_KEY = Deno.env.get("PAYME_KEY")?.trim();

const rpcError = (id: any, code: number, msgUz: string, msgRu: string, data?: string) => 
  new Response(JSON.stringify({ 
    jsonrpc: "2.0", id, 
    error: { 
      code, 
      message: { uz: msgUz, ru: msgRu, en: msgRu }, 
      ...(data && { data }) 
    } 
  }), { headers: { "Content-Type": "application/json" } });

const rpcSuccess = (id: any, result: any) => 
  new Response(JSON.stringify({ jsonrpc: "2.0", id, result }), { headers: { "Content-Type": "application/json" } });

serve(async (req) => {
  try {
    const auth = req.headers.get("authorization");
    const decoded = atob(auth?.split(" ")[1] ?? "");
    if (decoded !== `Paycom:${PAYME_KEY}`) return rpcError(null, -32504, "Auth error", "Ошибка авторизации");

    const { method, params, id } = await req.json();

    switch (method) {
      case "CheckPerformTransaction": {
        const userId = params.account.user_id?.toString().trim();
        const amount = Number(params.amount);

        if (amount !== 19000000) return rpcError(id, -31001, "Noto'g'ri summa", "Неверная сумма");

        const { data: user } = await supabase.from("profiles").select("id").eq("id", userId).maybeSingle();
        if (!user) return rpcError(id, -31050, "Foydalanuvchi topilmadi", "Пользователь не найден", "account");

        return rpcSuccess(id, {
          allow: true,
          detail: {
            receipt_type: 0,
            items: [{ title: "Uplift English Course", price: 19000000, count: 1, code: "10399001001000000", vat_percent: 0, package_code: "0000" }]
          }
        });
      }

      case "CreateTransaction": {
        const userId = params.account.user_id?.toString().trim();
        const amount = Number(params.amount);
        const transId = params.id.trim();
        const time = Number(params.time);

        if (amount !== 19000000) return rpcError(id, -31001, "Неверная сумма", "Неверная сумма");

        // 1. Profile Check
        const { data: user } = await supabase.from("profiles").select("id").eq("id", userId).maybeSingle();
        if (!user) return rpcError(id, -31050, "User not found", "Пользователь не найден", "account");

        // 2. Exact Transaction Check (Idempotency)
        const { data: existing } = await supabase.from("payme_transactions").select("*").eq("id", transId).maybeSingle();
        if (existing) {
          if (Number(existing.state) !== 1) return rpcError(id, -31008, "Bajarib bo'lmaydi", "Невозможно выполнить");
          return rpcSuccess(id, { create_time: Number(existing.create_time), transaction: existing.id, state: 1 });
        }

        // 3. THE FIX: STRICTOR PENDING CHECK
        // We query the table for any row where user matches AND state is 1.
        // If we find ANY, we block the new transaction.
        const { data: activeTx } = await supabase
          .from("payme_transactions")
          .select("id, state")
          .eq("account_user_id", userId)
          .eq("state", 1)
          .limit(1);

        if (activeTx && activeTx.length > 0) {
          // The Sandbox expects an error here because a transaction is already pending
          return rpcError(id, -31050, "Sizda kutilayotgan to'lov bor", "У вас есть активная транзакция", "account");
        }

        // 4. Create new transaction record
        const { error: insError } = await supabase.from("payme_transactions").insert({
          id: transId, 
          amount, 
          state: 1, 
          create_time: time, 
          account_user_id: userId
        });
        
        if (insError) return rpcError(id, -31008, "Database error", "Ошибка базы");
        return rpcSuccess(id, { create_time: time, transaction: transId, state: 1 });
      }

      case "PerformTransaction": {
        const transId = params.id.trim();
        const { data: tx } = await supabase.from("payme_transactions").select("*").eq("id", transId).maybeSingle();
        if (!tx) return rpcError(id, -31003, "Topilmadi", "Не найдено");
        if (Number(tx.state) === 1) {
          const now = Date.now();
          await supabase.from("payme_transactions").update({ state: 2, perform_time: now }).eq("id", transId);
          return rpcSuccess(id, { transaction: tx.id, perform_time: now, state: 2 });
        }
        if (Number(tx.state) === 2) return rpcSuccess(id, { transaction: tx.id, perform_time: Number(tx.perform_time), state: 2 });
        return rpcError(id, -31008, "Xato holat", "Неверное состояние");
      }

      case "CancelTransaction": {
        const transId = params.id.trim();
        const { data: tx } = await supabase.from("payme_transactions").select("*").eq("id", transId).maybeSingle();
        if (!tx) return rpcError(id, -31003, "Topilmadi", "Не найдено");
        if (Number(tx.state) === 1 || Number(tx.state) === 2) {
          const newState = Number(tx.state) === 1 ? -1 : -2;
          const now = Date.now();
          await supabase.from("payme_transactions").update({ state: newState, cancel_time: now, reason: params.reason }).eq("id", transId);
          return rpcSuccess(id, { transaction: tx.id, cancel_time: now, state: newState });
        }
        return rpcSuccess(id, { transaction: tx.id, cancel_time: Number(tx.cancel_time), state: Number(tx.state) });
      }

      case "CheckTransaction": {
        const transId = params.id.trim();
        const { data: tx } = await supabase.from("payme_transactions").select("*").eq("id", transId).maybeSingle();
        if (!tx) return rpcError(id, -31003, "Topilmadi", "Не найдено");
        return rpcSuccess(id, {
          create_time: Number(tx.create_time), perform_time: Number(tx.perform_time || 0), cancel_time: Number(tx.cancel_time || 0),
          transaction: tx.id, state: Number(tx.state), reason: tx.reason ? Number(tx.reason) : null
        });
      }

      case "GetStatement": {
        const { from, to } = params;
        const { data: txs } = await supabase.from("payme_transactions").select("*")
          .gte("create_time", from).lte("create_time", to).order("create_time", { ascending: true });
        const transactions = (txs || []).map(tx => ({
          id: tx.id, time: Number(tx.create_time), amount: Number(tx.amount),
          account: { user_id: tx.account_user_id },
          create_time: Number(tx.create_time), perform_time: Number(tx.perform_time || 0),
          cancel_time: Number(tx.cancel_time || 0), transaction: tx.id,
          state: Number(tx.state), reason: tx.reason ? Number(tx.reason) : null
        }));
        return rpcSuccess(id, { transactions });
      }

      default: return rpcError(id, -32601, "Metod topilmadi", "Метод не найден");
    }
  } catch (e) { return rpcError(null, -32603, "Internal error", "Внутренняя ошибка"); }
});