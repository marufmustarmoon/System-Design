# Idempotent Operations — বাংলা ব্যাখ্যা

_টপিক নম্বর: 076_

## গল্পে বুঝি

মন্টু মিয়াঁর client network timeout পেলে একই request আবার পাঠায়। যদি server প্রতিবার নতুন order/payment তৈরি করে ফেলে, তাহলে বড় সমস্যা।

`Idempotent Operations` টপিকটা একই request repeat হলেও unwanted duplicate side effect না হওয়ার design principle বোঝায়।

Retries production-এ normal; তাই idempotency payment, order creation, job submission, webhook processing - এসব জায়গায় খুব গুরুত্বপূর্ণ।

ইন্টারভিউতে idempotency key, dedup store, request identity, and replay window বললে answer practical হয়।

সহজ করে বললে `Idempotent Operations` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: An idempotent operation can be safely retried multiple times without changing the final result beyond the first successful execution।

বাস্তব উদাহরণ ভাবতে চাইলে `Amazon`-এর মতো সিস্টেমে `Idempotent Operations`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Idempotent Operations` আসলে কীভাবে সাহায্য করে?

`Idempotent Operations` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- retryable write/API path-এ duplicate side effect (double charge/order/job) প্রতিরোধের design explain করতে সাহায্য করে।
- idempotency key, dedup store, replay window, আর partial failure handling স্পষ্ট করতে সাহায্য করে।
- network timeout/retry-কে normal ধরে safe behavior design করার mindset তৈরি করে।
- payment/order/webhook/job submission-এর মতো critical flows-এ robust API semantics দিতে সাহায্য করে।

---

### কখন `Idempotent Operations` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → Any retriable write path (payments, booking, job submission, মেসেজ কনজিউমারগুলো).
- Business value কোথায় বেশি? → ডিস্ট্রিবিউটেড সিস্টেম রিট্রাই রিকোয়েস্টগুলো due to timeouts এবং transient ফেইলিউরগুলো.
- public API আর internal service call-এ একই protocol লাগবে নাকি আলাদা?
- timeout, retry, idempotency, versioning কীভাবে handle করবেন?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: It হলো rarely optional জন্য distributed writes; do না skip it যদি রিট্রাইগুলো exist.
- ইন্টারভিউ রেড ফ্ল্যাগ: Adding রিট্রাইগুলো on writes সাথে no deduplication strategy.
- Assuming `PUT` হলো automatically আইডেমপোটেন্ট regardless of সার্ভার behavior.
- Storing idempotency keys ছাড়া expiration/cleanup.
- Ignoring payload mismatch যখন the same key হলো reused incorrectly.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Idempotent Operations` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

---

### মন্টুর কেস (ধাপে ধাপে)

- ধাপ ১: duplicate-trigger risk থাকা operations identify করুন।
- ধাপ ২: idempotency key/request identity define করুন।
- ধাপ ৩: dedup/result store-এ key map করুন।
- ধাপ ৪: retry timeout window ও expiration policy ঠিক করুন।
- ধাপ ৫: partial failure case-এ same result return strategy বলুন।

---

### এই টপিকে মন্টু কী সিদ্ধান্ত নিচ্ছে?

- public API আর internal service call-এ একই protocol লাগবে নাকি আলাদা?
- timeout, retry, idempotency, versioning কীভাবে handle করবেন?
- debugging/tooling/compatibility-এর দিক থেকে এই protocol বেছে নেওয়ার কারণ কী?

---

## এক লাইনে

- `Idempotent Operations` retried request বারবার এলে duplicate side effect এড়িয়ে same logical result বজায় রাখার design টপিক।
- এই টপিকে বারবার আসতে পারে: idempotency key, deduplication, safe retries, duplicate side effects, retry window

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Idempotent Operations` একই request retry হলেও duplicate side effect না ঘটিয়ে safe repeated execution design বোঝায়।

- একটি আইডেমপোটেন্ট operation পারে হতে safely retried multiple times ছাড়া changing the final result beyond the first successful execution.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: Network timeout/retry সাধারণ ঘটনা; idempotency না থাকলে duplicate side effect (double charge/order/job) হতে পারে।

- ডিস্ট্রিবিউটেড সিস্টেম রিট্রাই রিকোয়েস্টগুলো due to timeouts এবং transient ফেইলিউরগুলো.
- Idempotency রোধ করে duplicate side effects.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: request identity, dedup store, retry window, partial failure behavior, এবং same-result replay semantics পরিষ্কার করা জরুরি।

- Common techniques: idempotency keys, deduplication tables, unique constraints, version checks, upserts.
- Idempotency হলো a property of operation semantics, না just HTTP method choice.
- এটি হলো essential জন্য payments, কিউগুলো, এবং async কনজিউমারগুলো যেখানে duplicate delivery হলো normal.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Idempotent Operations` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Amazon** payment/order APIs অনেক সময় ব্যবহার idempotency keys so ক্লায়েন্ট রিট্রাইগুলো do না create duplicate orders অথবা charges.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Idempotent Operations` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: Any retriable write path (payments, booking, job submission, মেসেজ কনজিউমারগুলো).
- কখন ব্যবহার করবেন না: It হলো rarely optional জন্য distributed writes; do না skip it যদি রিট্রাইগুলো exist.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"How would আপনি implement idempotency জন্য a `CreateOrder` API?\"
- রেড ফ্ল্যাগ: Adding রিট্রাইগুলো on writes সাথে no deduplication strategy.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Idempotent Operations`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Assuming `PUT` হলো automatically আইডেমপোটেন্ট regardless of সার্ভার behavior.
- Storing idempotency keys ছাড়া expiration/cleanup.
- Ignoring payload mismatch যখন the same key হলো reused incorrectly.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Adding রিট্রাইগুলো on writes সাথে no deduplication strategy.
- কমন ভুল এড়ান: Assuming `PUT` হলো automatically আইডেমপোটেন্ট regardless of সার্ভার behavior.
- ইন্টারভিউতে কখন ব্যবহার করবেন/করবেন না - দুইটাই বললে উত্তরের মান বাড়ে।
- কেন দরকার (শর্ট নোট): ডিস্ট্রিবিউটেড সিস্টেম রিট্রাই রিকোয়েস্টগুলো due to timeouts এবং transient ফেইলিউরগুলো.
