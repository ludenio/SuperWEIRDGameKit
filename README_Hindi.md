[English](README.md)        [Русский](README_Russian.md)        [中文](README_Chinese.md)        [हिन्दी](README_Hindi.md)        [Español](README_Spanish.md)        [Français](README_French.md)        [Deutsch](README_German.md)        [Português](README_Portuguese.md)        [日本語](README_Japanese.md)        [Bahasa Indonesia](README_Indonesian.md)        [Svenska](README_Swedish.md)        [Беларуская](README_Belarusian.md)        [Українська](README_Ukrainian.md)        [Polski](README_Polish.md)        [Nederlandse](README_Dutch.md)

# SuperWEIRD गेम किट

नमस्ते! [Luden.io](https://luden.io?utm_source=superweirdgamekit&utm_medium=github) पर हम [SuperWEIRD](https://superweird.shop?utm_source=superweirdgamekit&utm_medium=github) बना रहे हैं (गेम देखें [Steam](https://store.steampowered.com/app/3818770/SuperWEIRD/?utm_source=superweirdgamekit&utm_medium=github) पर)। यह [Defold](https://defold.com) इंजन पर बनी लेमिंग-जैसे रोबोट्स के साथ सिस्टम डिज़ाइन और ऑटोमेशन पर आधारित एक को-ऑप गेम है।

विकास के शुरुआती चरण में हमने विज़ुअल स्टाइल्स और गेमप्ले के साथ कई प्रयोग किए। हमें लगा कि ये अन्य डेवलपर्स के लिए उपयोगी हो सकते हैं, इसलिए हमने उन प्रयोगों का कोड, टेक्स्चर और एनीमेशन खुले [CC0](LICENSE) लाइसेंस के तहत जारी करने का निर्णय लिया।

इस रिपॉज़िटरी में आपको छह अलग-अलग विज़ुअल स्टाइल्स ([video](https://youtu.be/RJwOEDY3MP4)) और शॉप/प्रोडक्शन सिम्युलेटर की गेमप्ले लॉजिक मिलेगी। खिलाड़ी ग्राहक ऑर्डर पूरे करता है और उत्पादन का विस्तार करता है। आप [demo on itch.io](https://ludenio.itch.io/superweird-game-kit?utm_source=superweirdgamekit&utm_medium=github) खेल सकते हैं।

[![Project Video](youtube_intro_cover.png)](https://youtu.be/Jjm47KMF-V0)

हमारे [Discord](https://discord.gg/ludenio) से जुड़ें और बताएं कि आप इन प्रोटोटाइप्स से क्या बनाएंगे। या हमारे [YouTube channel](https://www.youtube.com/@ludenio) पर नज़र डालें — वहां बहुत बढ़िया चीज़ें हैं, जिनमें [SuperWEIRD dev diaries](https://www.youtube.com/@ludenio/videos) भी शामिल हैं।

लिंक:
- Discord (हम हर दिन वहाँ होते हैं): https://discord.gg/ludenio
- YouTube: https://www.youtube.com/@ludenio
- अपडेट्स और टेक्स्ट डेव डायरीज़ वाला न्यूज़लेटर: https://ludenio.substack.com/
- Twitter (X): https://x.com/luden_io

# साझेदार

[![Carina](carina_logo.png)](https://www.carina.fund/?utm_source=ludenio&utm_medium=superweirdwebsite&utm_campaign=carina_banner&utm_content=fun)

SuperWEIRD को [Carina Initiatives](https://www.carina.fund/?utm_source=ludenio&utm_medium=superweirdwebsite&utm_campaign=carina_banner&utm_content=fun) के सहयोग से बनाया जा रहा है — यह एक परोपकारी फंड है जो विविध समुदायों के बच्चों को विज्ञान और प्रौद्योगिकी तक पहुँच दिलाने के लिए काम करता है। उनका मानना है कि गणित भविष्य के नवाचारों की नींव है, और वे ऐसी संस्थाओं को फंड करते हैं जो गणितीय प्रतिभा को प्रेरित और विकसित करती हैं। अगर आप अन्य शैक्षिक प्रोजेक्ट्स में रुचि रखते हैं, तो Carina Initiatives के पार्टनर्स पर नज़र डालें:

[![NMS](nms_logo.png)](https://nationalmathstars.org/?utm_source=ludenio&utm_medium=superweirdwebsite)
[![Brilliant](brilliant_logo.png)](https://educator.brilliant.org/?utm_source=superweird&utm_medium=website&utm_campaign=carina_banner&utm_content=fun)
[![AoPS](aops_logo.png)](https://artofproblemsolving.com/alcumus?utm_source=superweird&utm_medium=display&utm_campaign=carina_alcumus_banner&utm_content=fun)

# क्विक स्टार्ट

1. Defold Editor इंस्टॉल करें: https://defold.com
2. रिपॉज़िटरी को क्लोन करें या डाउनलोड करें।
3. प्रोजेक्ट फ़ोल्डर को Defold Editor में खोलें।
4. प्रोजेक्ट को बिल्ड करें और रन करें।

नोट: Spine एनीमेशन एडिट करने के लिए Spine Editor की आवश्यकता होती है।

# प्रोजेक्ट संरचना

1. लोडिंग
   - `loader` — गेम के साथ शुरू होता है, मेमोरी में बना रहता है, और Collection Proxy के जरिए कलेक्शन्स को लोड/अनलोड मैनेज करता है; लॉन्च पर स्टार्ट मेन्यू को इनिशियलाइज़ करता है।
   - `menu` — स्टार्ट मेन्यू, जो गेम शुरू होने पर दिखाया जाता है।

2. मुख्य भाग
   - `main` — साझा गेम कोड: स्क्रिप्ट्स और मॉड्यूल्स जो सभी वर्ल्ड्स में उपयोग होते हैं; यहाँ पूरी गेम लॉजिक रहती है।
   - `assets` — गेम एसेट्स: टेक्स्चर, Spine मॉडल्स, टाइलमैप्स और एटलस। हर वर्ल्ड के लिए अलग फ़ोल्डर `world_1`, `world_2` आदि, जिनमें यूनिक विज़ुअल्स होते हैं।
   - `worlds` — वर्ल्ड्स की विज़ुअल सेटअप: कलेक्शन्स और गेम ऑब्जेक्ट्स। प्रत्येक वर्ल्ड `world_1`, `world_2` आदि में एक अलग कलेक्शन है।

3. अतिरिक्त
   - `SuperWEIRDGameKit_assets` — प्रोजेक्ट में उपयोग किए गए ग्राफिक्स और Spine मॉडल्स का सुव्यवस्थित सेट।

# वर्ल्ड मैनेजमेंट लॉजिक

- वर्ल्ड स्विचिंग `loader` के जरिए होती है, जो कलेक्शन्स को लोड और अनलोड करता है।
- वर्ल्ड कस्टमाइज़ेशन: विज़ुअल पैरामीटर्स और गेम ऑब्जेक्ट्स को `worlds/world_X` में अपडेट करें, और ग्राफिक्स को `assets/world_X` में।

## नया वर्ल्ड जोड़ना

1. `assets/world_N` और `worlds/world_N` फ़ोल्डर बनाएँ।
2. किसी मौजूदा वर्ल्ड से टेम्पलेट कॉपी करें।
3. नए वर्ल्ड को लोडर/मेन्यू कोड में रजिस्टर करें (लॉजिक देखें `main` में)।
4. सुनिश्चित करें कि कलेक्शन्स और एसेट्स सही तरीके से लिंक्ड हैं।
