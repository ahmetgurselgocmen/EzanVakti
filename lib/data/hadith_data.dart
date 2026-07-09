class Hadith {
  final int id;
  final String text;
  final String source;

  const Hadith({
    required this.id,
    required this.text,
    required this.source,
  });
}

class HadithData {
  static const List<Hadith> hadiths = [
    Hadith(
      id: 1,
      text: "Ameller niyetlere göredir.",
      source: "Buhari, Bed'ü'l-Vahy, 1",
    ),
    Hadith(
      id: 2,
      text: "Sizin en hayırlınız, Kur'an'ı öğrenen ve öğreteninizdir.",
      source: "Buhari, Fezailü'l-Kur'an, 21",
    ),
    Hadith(
      id: 3,
      text: "İslam güzel ahlaktır.",
      source: "Kenzü'l-Ummal, 3/17",
    ),
    Hadith(
      id: 4,
      text: "Kolaylaştırın, zorlaştırmayın. Müjdeleyin, nefret ettirmeyin.",
      source: "Buhari, İlim, 11",
    ),
    Hadith(
      id: 5,
      text: "Müslüman, elinden ve dilinden Müslümanların emin olduğu kimsedir.",
      source: "Buhari, İman, 4",
    ),
    Hadith(
      id: 6,
      text: "İki nimet vardır ki insanların çoğu bunda aldanmıştır: Sağlık ve boş vakit.",
      source: "Buhari, Rikak, 1",
    ),
    Hadith(
      id: 7,
      text: "Sizden biriniz kendisi için sevdiğini kardeşi için de sevmedikçe gerçek iman etmiş olamaz.",
      source: "Buhari, İman, 7",
    ),
    Hadith(
      id: 8,
      text: "Allah'a ve ahiret gününe iman eden ya hayır söylesin ya da sussun.",
      source: "Buhari, Edeb, 31",
    ),
    Hadith(
      id: 9,
      text: "Temizlik imanın yarısıdır.",
      source: "Müslim, Taharet, 1",
    ),
    Hadith(
      id: 10,
      text: "İnsanlara merhamet etmeyene Allah da merhamet etmez.",
      source: "Buhari, Tevhid, 2",
    ),
    Hadith(
      id: 11,
      text: "Cennet annelerin ayakları altındadır.",
      source: "Nesâî, Cihad, 6",
    ),
    Hadith(
      id: 12,
      text: "Dua ibadetin özüdür.",
      source: "Tirmizi, Daavat, 1",
    ),
    Hadith(
      id: 13,
      text: "Her duyduğunu söylemesi kişiye yalan olarak yeter.",
      source: "Müslim, Mukaddime, 5",
    ),
    Hadith(
      id: 14,
      text: "Kim bir hayra vesile olursa, o hayrı işleyen kadar sevap kazanır.",
      source: "Müslim, İmaret, 133",
    ),
    Hadith(
      id: 15,
      text: "Zulümden sakının. Çünkü zulüm kıyamet gününde zifiri karanlıktır.",
      source: "Müslim, Birr, 56",
    ),
    Hadith(
      id: 16,
      text: "Sadaka malı eksiltmez.",
      source: "Müslim, Birr, 69",
    ),
    Hadith(
      id: 17,
      text: "Bizi aldatan bizden değildir.",
      source: "Müslim, İman, 164",
    ),
    Hadith(
      id: 18,
      text: "İman yetmiş küsur şubedir.",
      source: "Müslim, İman, 58",
    ),
    Hadith(
      id: 19,
      text: "Allah her işi güzel yapmayı emretmiştir.",
      source: "Müslim, Sayd, 57",
    ),
    Hadith(
      id: 20,
      text: "Oruç bir kalkandır.",
      source: "Buhari, Savm, 2",
    ),
    Hadith(
      id: 21,
      text: "İki kişi arasındaki hükmü ancak Allah'ın kitabıyla veririm.",
      source: "Müslim, Akdiye, 4",
    ),
    Hadith(
      id: 22,
      text: "Misvak ağzı temizler, Rabbi hoşnut eder.",
      source: "Nesâî, Taharet, 5",
    ),
    Hadith(
      id: 23,
      text: "Mümin müminin aynasıdır.",
      source: "Ebu Davud, Edeb, 49",
    ),
    Hadith(
      id: 24,
      text: "Helal belli, haram da bellidir.",
      source: "Buhari, İman, 39",
    ),
    Hadith(
      id: 25,
      text: "Kıskançlıktan sakının. Ateşin odunu yakıp bitirdiği gibi, kıskançlık da iyilikleri yer bitirir.",
      source: "Ebu Davud, Edeb, 44",
    ),
    Hadith(
      id: 26,
      text: "Yarım hurma ile de olsa kendinizi ateşten koruyun.",
      source: "Buhari, Zekat, 9",
    ),
    Hadith(
      id: 27,
      text: "İşçiye ücretini teri kurumadan önce verin.",
      source: "İbn Mâce, Rühûn, 4",
    ),
    Hadith(
      id: 28,
      text: "Güler yüzle insanlara selam vermek de sadakadır.",
      source: "Tirmizi, Birr, 36",
    ),
    Hadith(
      id: 29,
      text: "Yemeği yediren, şükreden bir kimse; sabreden oruçlu gibidir.",
      source: "Tirmizi, Kıyame, 43",
    ),
    Hadith(
      id: 30,
      text: "Rüşvet alan da veren de ateştedir.",
      source: "Tirmizi, Ahkam, 9",
    ),
    Hadith(
      id: 31,
      text: "Büyüğümüze saygı göstermeyen, küçüğümüze şefkat etmeyen bizden değildir.",
      source: "Tirmizi, Birr, 15",
    ),
    Hadith(
      id: 32,
      text: "Söz taşıyan kimse cennete giremez.",
      source: "Buhari, Edeb, 50",
    ),
    Hadith(
      id: 33,
      text: "Allah sizin suretlerinize ve mallarınıza bakmaz, kalplerinize ve amellerinize bakar.",
      source: "Müslim, Birr, 34",
    ),
    Hadith(
      id: 34,
      text: "Din nasihattir.",
      source: "Müslim, İman, 95",
    ),
    Hadith(
      id: 35,
      text: "Öfke şeytandandır. Şeytan ise ateşten yaratılmıştır.",
      source: "Ebu Davud, Edeb, 3",
    ),
    Hadith(
      id: 36,
      text: "Ümmetimin en hayırlısı benim bulunduğum asırdır.",
      source: "Buhari, Fezailu's-Sahabe, 1",
    ),
    Hadith(
      id: 37,
      text: "Dünyada garip yahut yolcu gibi ol.",
      source: "Buhari, Rikak, 3",
    ),
    Hadith(
      id: 38,
      text: "Bir Müslümanın kardeşine üç günden fazla dargın durması helal olmaz.",
      source: "Buhari, Edeb, 57",
    ),
    Hadith(
      id: 39,
      text: "Namaz dinin direğidir.",
      source: "Tirmizi, İman, 8",
    ),
    Hadith(
      id: 40,
      text: "Sana şüphe veren şeyi bırak, şüphe vermeyene bak.",
      source: "Tirmizi, Kıyame, 60",
    ),
  ];
}
