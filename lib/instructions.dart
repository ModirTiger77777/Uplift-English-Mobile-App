import 'package:flutter/material.dart';
import 'package:flutter_application_1/formatted_text.dart';
import 'package:google_fonts/google_fonts.dart';

class InstructionsPage extends StatelessWidget {
  const InstructionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      appBar: AppBar(
        title: Text(
          "Ilovadan qanday foydalanish",
          style: GoogleFonts.roboto(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple.shade200,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FormattedText(
            "\n\n\n👋 Assalomu alaykum qadrli o'quvchilar! Ingliz tili olamiga xush kelibsiz! 🌍 "
            "Yer yuzidagi milliardlab insonlarni bog'lovchi ingliz tilini o'rganishga qaror qilganingiz bilan tabriklayman 🎉 "
            "va sizga bu yo'lingizda omad tilayman 🍀. Bugun biz bu sahifada ilovadan qanday foydalanish kerakligini 📱 "
            "va ushbu mobil ilovaning afzalliklari haqida so'z yuritamiz. 💡 "
            "Darhaqiqat ushbu o'quv dasturidan maksimal foyda olish uchun dastlab uni to'liq tushunib olish muhim. 🔑",
            context: context,
          ),
          const SizedBox(height: 16),

          Image.asset("images/home_page.webp",
              height: 220, fit: BoxFit.contain),
          const SizedBox(height: 16),

          FormattedText(
            "🏠 Ushbu rasmda siz mobil ilovamizning asosiy sahifasini ko'rishingiz mumkin. "
            "📑 Garchi bu yerdagi 4 ta sarlavha bu bo'limlar nima haqida ekanligini bildirib tursa-da "
            "ℹ️ biz ular bo'yicha qo'shimcha tushuntirishlar beramiz.",
            context: context,
          ),

          const SizedBox(height: 20),
          Image.asset("images/navbar.webp", height: 220, fit: BoxFit.contain),
          const SizedBox(height: 16),

          FormattedText(
            "📚 Birinchi bo'limimiz 'Asosiy darslar' sahifasida ilovamizning barcha 150 darslari joylashgan. "
            "✍️ Har bir darsimiz uch qismdan iborat: So'zlar, Hikoya, Grammatika. "
            "🔀 Agar so'zlardan hikoyalar yoki grammatika bo'limiga o'tmoqchi bo'lsangiz ilovaning pastki qismidagi 'YO'NALTIRGICH' dan foydalanasiz "
            "va bir darsning uch bo'limidan bir-biriga qulaylik bilan o'tasiz. "
            "Har bir darsda o'rtacha 20 ta so'z o'rganiladi. Yuklama hajmiga qarab 1 darsni 1 yoki 2 kunda tugatishingiz mumkin.",
            context: context,
          ),

          const SizedBox(height: 20),
          Image.asset("images/mnemonics.webp",
              height: 220, fit: BoxFit.contain),
          const SizedBox(height: 16),

          FormattedText(
            "Ilovaning o'ziga xos taraflaridan biri — u so'zlarni oson o'rganishda mnemonik assotsatsiyalardan, ya'ni bog'lanmalardan foydalanadi. 💡 "
            "Bu so'z, ism, raqam va sanalarni oson eslab qolish texnikasi bo'lib agar mnemonik usuldan qanday foydalanishni bilib olsangiz, lug'at yodlash ancha oson va tezroq bo'ladi ⚡. "
            "Juda ko'p insonlar mnemonik texnikalarni o'zlari bilmagan holatda ham qo'llashadi. 🤔\n\n"
            "Masalan, telefon raqamini eslab qolishda siz 'Nomer 72 96 bilan tugar ekan. 72 dadamning, 96 esa mening tug'ilgan yilim' 📞 "
            "deya noma'lum narsani o'zingiz bilgan ma'lum narsaga bog'laysiz. 🔗 "
            "Yoki Sardor ismli insonning ismini eslab qolish uchun bu ismni o'zingiz tanigan Sardorga bog'laysiz. 👤\n\n"
            "Chet tili so'zlarini yodlayodganda esa o'sha so'zga eshitilishi bir xil yoki yaqin bo'lgan o'zbekcha so'zni topamiz. 🔍 "
            "Keyin esa biz bu ikkalasini ishlatib kichik hikoya yoki voqea o'ylab topishimiz kerak. 📖 "
            "Masalan, yuqoridagi rasmda water (suv) so'zi uchun Botir so'zi tanlangan va ikkala so'z ishtirokida kichik hikoyacha yozilgan. Mnemonika orqali so'zni mashq qilish davomida inglizcha so'zni bir necha bor ovoz chiqarib takrorlashingiz kerak. "
            "Ha, aytganchi, ilovamizda assotsatsiya qilingan o'zbekcha so'zlar pushti 🎀, tarjima so'zlar esa sariq rang bilan belgilangan. 🟡\n\n"
            "Umuman olganda, mnemonika yordamida raqam, so'z, inson qiyofasi va boshqa ma'lumotlarni tez yodlash yurtimizda Davronbek Turdiyev tomonidan ommalashtirildi. 📚 "
            "Uning o'zi esa Rossiyadagi teleshouda 250 ta tovarning shtrix kodini ketma-ketlikda aytib berib 🛒 Sobiq Ittifoq davlatlarida mashhurlikka erishgan. 🌟\n\n"
            "Mnemonik qismni kichkina bir matnda qanchalik tushuntirib bera oldim bilmayman. 🤷‍♂️ "
            "Agar bir marta o'rganib olsangiz, bu juda kuchli usul 🔑. "
            "Agar 'bu men uchun emas' desangiz, mnemonik hikoyalar qismini shunchaki tashlab ketishingiz 😅 "
            "va so'zni yaxshiroq o'rganish uchun 4 ta misol va hikoya qismiga e'tibor qaratishingiz mumkin. 📖🎧\n\n"
            "Sizlar yaxshiroq tushuncha hosil qilishingiz uchun men bir nechta YouTube videolariga ssilka, ya'ni havolalar beraman. 🔗▶️\n\n"
            "1. [link=https://www.youtube.com/watch?v=ovLcX5vOd6A&t=324s]TOG usuli[/link]\n\n"
            "2. [link=https://www.youtube.com/watch?v=npVO2ocrqko&t=2107s]Tez so'z yodlash sirlari[/link]\n\n"
            "3. [link=https://www.youtube.com/watch?v=EUnL_FuPakM&t=103s]SO’Z YODLASH SIRLARI. MNEMONIKA[/link]\n\n"
            "4. [link=https://www.youtube.com/watch?v=6ZFGHb88dww&t=638s]Tez so'z yodlash sirlari - Muhammadali Abdullayev[/link]",
            context: context,
          ),

          const SizedBox(height: 20),
          Image.asset("images/ordinary_word.webp",
              height: 220, fit: BoxFit.contain),
          const SizedBox(height: 16),

          FormattedText(
            "📌 Lekin hamma so'zlar uchun ham mnemonik hikoyalar taqdim etilmagan. "
            "Ular asosan o'zak so'zlar uchun berilgan. "
            "Masalan interest (qiziqish) ni o'zak so'z sifatida olsak undan kelib chiqqan bir nechta so'zlar bor: interesting, interested, interestingly. "
            "Har bir qo'shimcha so'zga mnemonik bog'lanmalar tayyorlashdan ko'ra ularning qaysi o'zak so'zdan ekanligini aytish foydaliroq deb o'ylaymiz. "
            "Siz mana bu rasmda ko'rib turgan so'zning ham shunchaki tarjimasi yozilgan va uni tasvirlovchi rasm taqdim etilgan. "
            "🖼️ Tasvirlovchi rasmlar ham so'z yodlash uchun foydali texnika bo'lib o'quvchi miyasini yaxshiroq eslab qolishga undaydi. 🧠",
            context: context,
          ),

          const SizedBox(height: 20),
          Image.asset("images/dictionary.webp",
              height: 220, fit: BoxFit.contain),
          const SizedBox(height: 16),

          FormattedText(
            "📖 Bundan tashqari dasturimizning yana bir qulay funksiyasi bu ilovaga integratsiya qilingan inglizcha lug'at. "
            "🔎 Har safar o'zingizga notanish so'zga duch kelganingizda shunchaki so'z ustiga ikki marta bosasiz 👆 "
            "va ushbu so'zning o'zbekcha tarjimasi 🇺🇿 va talaffuz audiosi 🔊 paydo bo'ladi.",
            context: context,
          ),

          const SizedBox(height: 20),
          Image.asset("images/mnemonics.webp",
              height: 220, fit: BoxFit.contain),
          const SizedBox(height: 16),

          FormattedText(
            "🗣️ Ingliz tili o'zbek tilidan farqli o'laroq yozilishi va o'qilishi birmuncha farq qiluvchi til. "
            "Shuning uchun har bir so'zni o'rganayotganda talaffuziga e'tibor berish kerak 👂. "
            "Shu maqsadda o'rganilayotgan har bir so'zning fonetik transkripsiyasi 🔤 va talaffuz audiosi 🎧 taqdim etiladi. "
            "📢 Har bir so'zni o'rganish uchun berilgan 4 ta gapda va hikoyalar qismidagi 5 ta hikoya uchun audio mavjud bo'lib "
            "siz ingliz tilida so'zlar qanday eshitilishi va talaffuz etilishini o'rganasiz.",
            context: context,
          ),

          const SizedBox(height: 16),

          FormattedText(
            "📘 Grammatik mavzularimiz Essential Grammar in Use ya'ni qizil va ko'k Murphy kitoblari mavzulari bilan bir xil ketma-ketlikda. "
            "📖 Ushbu kitob O'zbekistonlik ingliz tili o'rganuvchilar orasida mashhur. "
            "Bizning ilova grammatikasi Myorfi kitobiga qo'shimcha o'zbekcha tushuntirish va misollar beradi. "
            "🎯 Ya'ni Myorfidan ingliz tili grammatikasini o'rganayotgan talaba bizning ilova orqali grammatikasini mustahkamlashi "
            "va so'zlar hamda matnlarni qo'shimcha ravishda o'rganishi mumkin.",
            context: context,
          ),

          const SizedBox(height: 20),
          Image.asset("images/story_part.webp",
              height: 220, fit: BoxFit.contain),
          const SizedBox(height: 16),

          FormattedText(
            "📖 Uchinchi qism hikoyalar bo'lib, o'rganuvchilar yangi o'rganilgan so'zlarni va grammatik mavzuni mustahkamlashlari uchun 5 ta hikoya beriladi. "
            "✍️ Bu hikoyalar asosan shu mavzuning so'zlari va grammatik qoidalaridan tashkil topadi.",
            context: context,
          ),
          const SizedBox(height: 16),

          FormattedText(
            "💡 [b]Ha aytganchi eng muhim eslatma[/b]! Foydalanuvchilarga qiziqarli interfeysni hosil qilish uchun 1. So'zlar 2. Hikoya 3.Grammatika tarzida ketma-ketlik berilgan. Lekin darsni yaxshi o'zlashtirish uchun albatta avval Grammatika bo'limini o'rganib keyin So'zlar qismiga va nihoyat Hikoyalar qismi o'tilishi kerak. Ya'ni bu yerdagi formula [b]3-1-2[/b] bo'lishi lozim.",
            context: context,
          ),

          // ========================
          // Ilovaning afzalliklari
          // ========================
          const SizedBox(height: 24),
          const Center(
            child: Text(
              "🌟 Ilovaning afzalliklari 🌟",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          FormattedText(
            "1️⃣ So'zlar qismidagi turli rasmlar va ular ostidagi kichik matnlardan hayratlangan bo'lishingiz mumkin. 🖼️ "
            "Bular so'zlar oson yodda qolish uchun berilgan mnemonik bog'lanmalar.",
            context: context,
          ),
          const SizedBox(height: 12),
          FormattedText(
            "2️⃣ Ilova ingliz tilini o'rganishni birmuncha tezlashtiradi ⚡. "
            "Shunchaki notanish so'z ustiga bir marta bosish orqali ularning ma'nosini darhol bilib olasiz va vaqtni tejaysiz ⏳.",
            context: context,
          ),
          const SizedBox(height: 12),
          FormattedText(
            "3️⃣ Ilovaning so'zlar va hikoyalar qismida audio 🎧 mavjud. "
            "Mikrofon belgisi 🎤 ustiga bosib so'zlarning to'g'ri talaffuzini o'rganasiz.",
            context: context,
          ),
          const SizedBox(height: 12),
          FormattedText(
            "4️⃣ Ilova 'spaced repetition'(oraliqli takrorlash) usulini qo'llaydi. Ya'ni siz bugun o'rgangan so'z 3-4 darsdan so'ng yana qaysidir hikoyada yoki misollarda qo'llaniladi."
            "Bu usul orqali o'rganilgan so'zlarni esdan chiqarib yubormaysiz.",
            context: context,
          ),
          const SizedBox(height: 12),
          FormattedText(
            "5️⃣ Dasturimizning grammatika qismi 📘 Murphy kitobidagi mavzular ketma-ketligiga ega. "
            "Qo'shimcha o'zbekcha tushuntirishlar 🇺🇿 va ko'proq misollar 📖 bilan taqdim etiladi.",
            context: context,
          ),
          const SizedBox(height: 12),
          FormattedText(
            "6️⃣ Grammatika qismi soddalashtirilgan bo'lib 😊 rasmli emojilar bilan yanada qiziqarli qilinadi. "
            "Abituriyentlar esa hikoyalarni o'qish orqali 📚 Reading qobiliyatlarini mustahkamlashlari mumkin.",
            context: context,
          ),

          // ================================
          // Ilova kim uchun va kim uchun emas
          // ================================
          const SizedBox(height: 30),
          const Center(
            child: Text(
              "🎯 Ilova kim uchun va kim uchun emas 🎯",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          FormattedText(
            "1️⃣ [b]Boshlang'ich o'rganuvchilar[/b]. Bu dastur taxminan boshlang'ich 3000 ta so'z va 150 grammatik mavzuni o'rgatadi va boshlang'ich o'rganuvchilar uchun yaxshi o'quv qo'llanma. "
            "Lekin agar siz taxminan 2000 ta so'z bilsangiz va yetarlicha ingliz tili bazangiz bo'lsa siz boshqa manbalardan foydalanganingiz afzal.",
            context: context,
          ),
          const SizedBox(height: 12),
          FormattedText(
            "2️⃣ [b]So'z yodlashda qiyinchilikka duch kelayotgan o'rganuvchilar[/b]. Ha, inglizcha so'zlarni oson o'zlashtirishda, o'rganuvchilarga yordam berish bu bizning asosiy fokusimiz. "
            "Bu yo'lda mnemonik vositalar va spaced repetition (oraliq takrorlash) usullaridan keng foydalanamiz.",
            context: context,
          ),
          const SizedBox(height: 12),
          FormattedText(
            "3️⃣ “[b]Til o‘rganish men uchun emas[/b]” deydiganlar uchun. Bu ilova so‘zlar va grammatik mavzularni detallashtirgan holatda o‘rgatadi va o‘quvchiga yengillik yaratadi. "
            "Umuman olganda, har bir inson chet tilini o‘rgana olish layoqatiga ega. Inson xorijiy til bilan qanchalik ko‘p kontaktni amalga oshirsa, "
            "ya’ni chet tili so‘zlarini eshitsa, o‘qisa, filmlar tomosha qilsa, suhbatlashsa, uning o‘sha tildagi ravonligi oshib boraveradi.",
            context: context,
          ),
          const SizedBox(height: 12),
          FormattedText(
            "4️⃣ [b]Ba'zi abituriyentlar uchun[/b]. Agar abituriyent bo‘lsangiz va atrofingizda davlat universitetlariga tayyorlovchi yaxshi o‘qituvchi bo‘lsa, biz o‘sha o‘qituvchi bilan ishlashingizni tavsiya qilamiz. "
            "Chunki ular sizga testlar yechtiradi, qattiqo‘llik bilan o‘qitadi, boshqa abituriyentlar bilan fikr almashasiz va foydali raqobatni ham his qilasiz.\n\n"
            "[b]Lekin[/b] agar atrofingizda malakali mutaxassis bo‘lmasa, repetitorga qatnash uchun uzoq masofaga qatnashga to‘g‘ri kelsa, mustaqil tayyorlanishni xohlasangiz "
            "yoki boshqa sabablarga ko‘ra davlat imtihonlariga tayyorlanish uchun ushbu ilovadan foydalanmoqchi bo‘lsangiz, eslatib o‘tamiz: "
            "siz bizning ilova bilan bir qatorda ba’zi qo‘shimcha vositalar — masalan, har yili chiqadigan yashil test kitoblari va Murphy grammar kitoblaridan ham foydalaning. "
            "Shuningdek, mustaqil o‘rganayotgan abituriyentlar intizomli va o‘ziga nisbatan talabchan bo‘lishi kerak.",
            context: context,
          ),
          const SizedBox(height: 12),
          FormattedText(
            "5️⃣ [b]Chet elda ishlashni xohlovchilar va chet eldagilar[/b]. Ilova orqali qat’iy dars soatlarisiz kunning xohlagan paytida, yuklamalarni ham o‘zingiz belgilagan holda til o‘rganishingiz mumkin. "
            "Va xorijiy davlatlarda ishlash uchun “tilni bilmaymanku” degan xavotirsiz harakat qilishingiz mumkin.",
            context: context,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
