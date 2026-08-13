import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { createHash } from "node:crypto";

const SECRET_KEY = "SFROMuc8QIxE"; 

Deno.serve(async (req) => {
  try {
    const formData = await req.formData();
    const data = Object.fromEntries(formData.entries());

    const click_trans_id = String(data.click_trans_id || "");
    const service_id = String(data.service_id || "");
    const merchant_trans_id = String(data.merchant_trans_id || ""); 
    const action = String(data.action || "");
    const sign_time = String(data.sign_time || "");
    const sign_string = String(data.sign_string || "");
    const merchant_prepare_id = String(data.merchant_prepare_id || ""); 
    
    let amount = String(data.amount || "");
    if (amount.includes('.')) {
      amount = Math.floor(parseFloat(amount)).toString();
    }

    // 1. MD5 IMZOSINI TEKSHIRISH
    let rawString = "";
    if (action === "0") {
      rawString = `${click_trans_id}${service_id}${SECRET_KEY}${merchant_trans_id}${amount}${action}${sign_time}`;
    } else {
      rawString = `${click_trans_id}${service_id}${SECRET_KEY}${merchant_trans_id}${merchant_prepare_id}${amount}${action}${sign_time}`;
    }

    const mySign = createHash('md5').update(rawString).digest('hex');

    if (mySign !== sign_string) {
      return new Response(JSON.stringify({ error: -1, error_note: "SIGN_CHECK_FAILED" }),
        { headers: { "Content-Type": "application/json" } });
    }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    );

    // 2. PREPARE BOSQICHI (Action 0)
    if (action === "0") {
      return new Response(JSON.stringify({
        click_trans_id: Number(click_trans_id),
        merchant_trans_id: merchant_trans_id,
        merchant_prepare_id: merchant_trans_id,
        error: 0,
        error_note: "Success"
      }), { headers: { "Content-Type": "application/json" } });
    }

    // 3. COMPLETE BOSQICHI (Action 1)
    if (action === "1") {
      console.log("To'lovni qayd qilish boshlandi...");

      // UPSERT - Bu qism jadvalda qator bo'lmasa uni yaratadi, bo'lsa yangilaydi
      const { error: upsertError } = await supabase
        .from('click_payments')
        .upsert({ 
          user_id: merchant_trans_id, // Flutter'dan transaction_param sifatida User ID kelyapti
          merchant_trans_id: merchant_trans_id, 
          status: 'paid', 
          click_trans_id: click_trans_id,
          amount: Math.floor(parseFloat(amount))
        }, { onConflict: 'merchant_trans_id' });

      if (upsertError) {
        console.error("click_payments jadvaliga yozishda xato:", upsertError);
      }

      // Foydalanuvchini premium qilish
      const { error: profileError } = await supabase
        .from('profiles')
        .update({ is_premium: true }) 
        .eq('id', merchant_trans_id);

      if (profileError) {
        console.error("Profiles jadvalini yangilashda xato:", profileError);
        return new Response(JSON.stringify({ error: -9, error_note: "DATABASE_ERROR" }),
          { headers: { "Content-Type": "application/json" } });
      }

      return new Response(JSON.stringify({
        click_trans_id: Number(click_trans_id),
        merchant_trans_id: merchant_trans_id,
        error: 0,
        error_note: "Success"
      }), { headers: { "Content-Type": "application/json" } });
    }

    return new Response(JSON.stringify({ error: -3, error_note: "ACTION_NOT_FOUND" }),
      { headers: { "Content-Type": "application/json" } });

  } catch (err) {
    console.error("Kutilmagan xato:", err);
    return new Response(JSON.stringify({ error: -9, error_note: "INTERNAL_SERVER_ERROR" }),
      { headers: { "Content-Type": "application/json" } });
  }
});