# خطة دمج اشتراك VIP (Listenly App)

تهدف هذه الخطة إلى بناء نظام اشتراكات (VIP) احترافي وعالي الأمان. تعتمد الخطة على حماية الروابط الفعلية للملفات في قاعدة البيانات (Supabase) بحيث لا يتم إرسالها إلا للمشتركين، بالإضافة إلى نظام باقات وفواتشرز متكامل.

---

## Proposed Changes

### 1. Database (Supabase)

#### [NEW] `listenly_app.subscription_packages` (Table)
جدول لتعريف أنواع الباقات المتوفرة:
- `id` (INT - PK)
- `name` (VARCHAR - UNIQUE) - مثال: `free_trial`, `monthly_sub`, `yearly_sub`, `lifetime`.
- `duration_days` (INT) - عدد أيام الباقة (مثلاً 7 للأسبوع التجريبي).

#### [NEW] `listenly_app.user_subscriptions` (Table)
جدول لتتبع حالة اشتراك المستخدم:
- `user_id` (UUID - PK)
- `is_lifetime` (BOOLEAN)
- `expires_at` (TIMESTAMP)
- `updated_at` (TIMESTAMP)

#### [NEW] `listenly_app.vouchers` (Table)
جدول الفواتشرز مربوط بجدول الباقات:
- `id` (INT - PK)
- `code` (VARCHAR - UNIQUE)
- `package_id` (INT - FK) - يربط الكوبون بباقة معينة.
- `max_uses` (INT)
- `current_uses` (INT)

#### [NEW] `listenly_app.used_vouchers` (Table)
لمنع استخدام الفواتشر مرتين لنفس المستخدم.

#### [MODIFY] `get_localized_lessons` (RPC)
تعديل الكود المصدري للدالة (SQL Function) الحالية الموجودة في قاعدة بياناتك:
1. جلب تاريخ الانتهاء (`expires_at`) للمستخدم الذي قام بالطلب (`p_user_id`).
2. تحديد ما إذا كان المستخدم VIP.
3. عند استخراج بيانات الدروس، إذا كان المستخدم **ليس VIP**، نجعل حقلي `audio_file_url` و `srt_file_url` قيمتهما `NULL`.
4. الدالة ستستمر في عملها القديم مع هذه الإضافة الأمنية فقط.

#### [NEW] Database Trigger: `on_user_created_create_trial`
- **الحدث**: عند إضافة صف جديد في `auth.users`.
- **الإجراء**:
  يقوم بإنشاء Voucher مربوط بباقة `free_trial`، وتطبيقه تلقائياً في `user_subscriptions` لتفعيل الـ 7 أيام المجانية فوراً.

#### [NEW] RPC: `redeem_voucher(p_code VARCHAR)`
لمعالجة إدخال أي كود فواتشر من التطبيق.

---

### 2. Backend Integration (Payments)

#### [NEW] RevenueCat Integration
- استخدام أدوات RevenueCat (`purchases_flutter`).
- ربط Webhooks الخاصة بـ RevenueCat لتحديث جدول `user_subscriptions` (تمديد تاريخ `expires_at`).

---

### 3. App (Flutter Presentation & Logic)

#### [NEW] `SubscriptionCubit`
Cubit عالمي يتصل بـ Supabase لمعرفة حالة اشتراك المستخدم (`isVip`) ويحتفظ بها. هذا المنطق سيتم استخدامه في طبقة الـ UI.

#### [MODIFY] UI Updates (Lessons List)
- الاستمرار في استخدام البيانات القادمة من الـ RPC كما هي.
- إضافة رسم "أيقونة قفل" على الدروس في حال كانت حالة المستخدم (`isVip` من `SubscriptionCubit`) تساوي False.
- منع النقر على الدرس المقفول، وبدلاً من ذلك إظهار شاشة الـ Paywall.

#### [NEW] `PaywallScreen` (UI)
- شاشة تُعرض عند الضغط على درس مقفول (أو من الإعدادات).
- تحتوي على الأسعار.
- تحتوي على مكان لإدخال "Voucher Code".

---

## Verification Plan

1. **اختبار قاعدة البيانات**: 
   - تحديث الـ RPC `get_localized_lessons` وتجربته عبر Supabase SQL Editor كشخص غير مشترك للتأكد من حجب الروابط مع الحفاظ على باقي البيانات (العنوان، الصورة... الخ).
2. **اختبار التطبيق**:
   - الدخول كشخص انتهت فترة اشتراكه، والتأكد من ظهور الأقفال وعدم القدرة على الدخول للمشغل.
