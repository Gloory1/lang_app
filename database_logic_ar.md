# **التصميم النهائي لقاعدة بيانات تطبيق تعلم اللغات**
# **(Supabase / PostgreSQL)**

يعتمد هذا التصميم على الجداول المستقلة لكل نوع من أنواع المحتوى (قصص، بودكاست، محادثات). ملاحظة: تم إلغاء جداول التزامن والترجمات نظراً للاعتماد على ملفات صوتية بصيغة (MKA) والتي تحتوي على النصوص المدمجة بداخلها. تم الاعتماد على جداول ترجمة مستقلة لتسهيل إدارة واجهة التطبيق بلغات متعددة، وجداول مفضلة مستقلة، بالإضافة إلى جداول "تتبع التقدم" (Progress Tracking) الذكية، ونظام إدارة المفردات والقاموس المركزي.

## **1\. الجداول المرجعية (Reference Tables)**

### **جدول اللغات (languages)**

* id (PK): UUID  
* code: String (e.g., 'en', 'es', 'ar')  
* lang\_name: String (e.g., 'English', ‘Spanish’, 'Arabic')  
* lang\_name\_native: String (e.g., 'English', ‘Español’, 'العربية')  
* lang\_flag\_icon\_url: String (اختياري \- رابط أيقونة أو علم اللغة)

### **جدول المستويات (levels)**

* id (PK): UUID  
* label: String (e.g., 'Beginner', 'Intermediate', 'Advanced')

### **جدول التصنيفات (genres)**

يستخدم لتوحيد التصنيفات (خيالي، تاريخي، تكنولوجيا، أعمال) عبر جميع أنواع المحتوى.

* id (PK): UUID  
* genre: String (e.g., 'Technology', 'Fantasy', 'Business')  
* cover\_image\_url: String (اختياري)

## **2\. جداول المحتوى الأساسي (Content Tables)**

هذه الجداول تحتوي على البيانات باللغة الأساسية (الافتراضية).

### **جدول القصص (stories\_lessons)**

* id (PK): UUID  
* title: String  
* description: Text  
* cover\_image\_url: String  
* level\_id (FK): UUID  
* target\_lang\_id (FK): UUID (اللغة المستهدفة بالتعلم في هذه القصة)  
* genre\_id (FK): UUID  
* audio\_mka\_url: String  
* author\_name: String  
* created\_at: Timestamp

### **جدول البودكاست (podcast\_lessons)**

* id (PK): UUID  
* title: String  
* description: Text  
* cover\_image\_url: String  
* level\_id (FK): UUID  
* target\_lang\_id (FK): UUID  
* genre\_id (FK): UUID  
* audio\_mka\_url: String  
* host\_name: String (اسم المضيف)  
* guest\_name: String (اسم الضيف \- اختياري)  
* created\_at: Timestamp

### **جدول المحادثات (conversations\_lessons)**

* id (PK): UUID  
* title: String  
* description: Text  
* cover\_image\_url: String  
* level\_id (FK): UUID  
* target\_lang\_id (FK): UUID  
* genre\_id (FK): UUID  
* scenario\_type: String  
* speaker\_one\_name: String (اسم المتحدث الأول)  
* speaker\_two\_name: String (اسم المتحدث الثاني)  
* created\_at: Timestamp

## **3\. الجداول التفاعلية والبيانات الوصفية (Metadata, Interactions)**

### **3.1 جداول الترجمة (Translations Tables)**

تم إنشاء جدول ترجمة مخصص لكل كيان لتجنب التعقيد وتسريع الاستعلامات الخاصة بواجهة المستخدم.

* **genres\_info\_translations**: (id, genre\_id, language\_id, translated\_name)  
* **stories\_lessons\_info\_translations**: (id, story\_id, language\_id, translated\_title, translated\_description)  
* **podcast\_lessons\_info\_translations**: (id, podcast\_id, language\_id, translated\_title, translated\_description)  
* **conversations\_lessons\_info\_translations**: (id, conversation\_id, language\_id, translated\_title, translated\_description)

### **3.2 جداول المفضلة (Favorites Tables)**

تم فصل المفضلة ليكون لكل نوع محتوى جدول خاص به.

* **stories\_lessons\_favorites**: (id, user\_id, story\_id, created\_at)  
* **podcast\_lessons\_favorites**: (id, user\_id, podcast\_id, created\_at)  
* **conversations\_lessons\_favorites**: (id, user\_id, conversation\_id, created\_at)

### **3.3 جداول تتبع التقدم (Progress Tracking)**

تتبع ذكي يتيح استئناف الاستماع ومعرفة الدروس المكتملة. إذا لم يكن هناك سجل، فالدرس "لم يبدأ".

* **stories\_lessons\_progress**: (id, user\_id, story\_id, position\_ms, is\_completed, completed\_at, updated\_at)  
* **podcast\_lessons\_progress**: (id, user\_id, podcast\_id, position\_ms, is\_completed, completed\_at, updated\_at)  
* **conversations\_lessons\_progress**: (id, user\_id, conversation\_id, position\_ms, is\_completed, completed\_at, updated\_at)

## **4\. المفردات والقاموس (Vocabulary & Dictionary)**

تم تصميم هذا القسم لفصل المفردات الخاصة بكل درس، مع ربطها بقاموس مركزي شامل يترجم الكلمات بين اللغات.

### **4.1 جداول مفردات الدروس (Lesson Vocabulary)**

يحتوي كل جدول على الكلمات المهمة في الدرس، وتكون الكلمة مكتوبة **باللغة المستهدفة (لغة الدرس)**.

* **stories\_lessons\_vocabulary**: (id, story\_id, word)  
* **podcast\_lessons\_vocabulary**: (id, podcast\_id, word)  
* **conversations\_lessons\_vocabulary**: (id, conversation\_id, word)

### **4.2 القاموس المركزي (global\_dictionary)**

جدول شامل يربط أي كلمة من لغة مستهدفة بترجمتها في اللغة الأصلية للمستخدم.

* id (PK): UUID  
* target\_lang\_id (FK): UUID (لغة الكلمة المراد تعلمها)  
* native\_lang\_id (FK): UUID (لغة المستخدم الأصلية)  
* target\_word: String (الكلمة باللغة المستهدفة)  
* translated\_word: String (الكلمة مترجمة للغة الأصلية)

*كيف تعمل معاً؟* للحصول على مفردات محادثة معينة للمستخدم، التطبيق يجلب الكلمات من conversations\_lessons\_vocabulary ويبحث عن ترجمتها في global\_dictionary بناءً على لغة المستخدم الأصلية (native\_lang\_id).
