# Claim Check — বাংলা ব্যাখ্যা

_টপিক নম্বর: 110_

## গল্পে বুঝি

মন্টু মিয়াঁ `Claim Check` টপিকটি নিয়ে কাজ করছেন কারণ সব processing synchronous রাখলে request path ভারী হয়ে যাচ্ছে।

Messaging/async patterns burst smoothing, decoupling, and independent scaling-এ সাহায্য করে, কিন্তু delivery semantics ও operational complexity বাড়ায়।

এখানে ordering, retries, idempotency, DLQ, schema evolution, and tracing - এগুলো বাদ দিলে design অসম্পূর্ণ।

ইন্টারভিউতে এই টপিকগুলোতে flow diagram-এর সাথে failure path explain করলে দ্রুত clarity আসে।

সহজ করে বললে `Claim Check` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: Claim check is a pattern where large payloads are stored externally (e.g., object storage) and messages carry only a reference/handle।

বাস্তব উদাহরণ ভাবতে চাইলে `YouTube`-এর মতো সিস্টেমে `Claim Check`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Claim Check` আসলে কীভাবে সাহায্য করে?

`Claim Check` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- sync request path থেকে async workflow আলাদা করে decoupling ও burst smoothing design করতে সাহায্য করে।
- delivery semantics, retries, idempotency, DLQ, ordering, এবং lag—এসব operational concern structuring করে।
- producer/consumer responsibility ও failure path পরিষ্কার করে।
- workflow orchestration/notification/analytics-এর মতো fan-out flow cleanভাবে explain করতে সহায়তা করে।

---

### কখন `Claim Check` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → Large files, large documents, media processing pipelines.
- Business value কোথায় বেশি? → মেসেজ brokers এবং APIs perform poorly সাথে very large payloads; large মেসেজগুলো এছাড়াও increase খরচ এবং রিট্রাই impact.
- কোন কাজ sync থাকবে, কোন কাজ queue/event-এ যাবে?
- delivery guarantee কী: at-most-once, at-least-once, না idempotent retry সহ?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: Small মেসেজগুলো যেখানে extra storage round-trip adds unnecessary complexity.
- ইন্টারভিউ রেড ফ্ল্যাগ: Sending huge blobs directly মাধ্যমে the কিউ/broker.
- কোনো cleanup জন্য orphaned payload objects.
- Missing অথরাইজেশন checks on claim-check retrieval.
- না handling payload/version mismatch.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Claim Check` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

---

### মন্টুর কেস (ধাপে ধাপে)

- ধাপ ১: producer/consumer roles নির্ধারণ করুন।
- ধাপ ২: message schema ও durability guarantee বলুন।
- ধাপ ৩: retry/idempotency/DLQ policy দিন।
- ধাপ ৪: ordering/back pressure/consumer lag handle করুন।
- ধাপ ৫: monitoring + tracing দিয়ে pipeline observe করুন।

---

### এই টপিকে মন্টু কী সিদ্ধান্ত নিচ্ছে?

- কোন কাজ sync থাকবে, কোন কাজ queue/event-এ যাবে?
- delivery guarantee কী: at-most-once, at-least-once, না idempotent retry সহ?
- consumer slow হলে back pressure/DLQ/retry policy কীভাবে কাজ করবে?

---

## এক লাইনে

- `Claim Check` async processing, queue/event flow, delivery behavior, এবং retry/idempotency design-এর টপিক।
- এই টপিকে বারবার আসতে পারে: claim, check, use case, trade-off, failure case

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Claim Check` async workflow, queue/event contract, delivery behavior, এবং decoupling pattern বোঝার ভিত্তি দেয়।

- Claim check হলো a pattern যেখানে large payloads হলো stored externally (যেমন, object storage) এবং মেসেজগুলো carry শুধু a reference/handle.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: সব কাজ synchronous রাখলে request path ভারী হয়; async decoupling ও workload smoothing-এর জন্য messaging pattern দরকার।

- মেসেজ brokers এবং APIs perform poorly সাথে very large payloads; large মেসেজগুলো এছাড়াও increase খরচ এবং রিট্রাই impact.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: delivery semantics, ordering, retries, idempotency, DLQ, এবং consumer lag/throughput behavior ব্যাখ্যা করা জরুরি।

- প্রোডিউসার stores payload in durable storage, then sends a small মেসেজ সাথে metadata এবং a pointer.
- কনজিউমারগুলো fetch the payload যখন needed এবং process it.
- ট্রেড-অফ: smaller, faster messaging এবং better broker থ্রুপুট vs extra storage lookup এবং lifecycle/সিকিউরিটি management.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Claim Check` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **YouTube** pipelines পারে pass video file references in মেসেজগুলো যখন/একইসাথে the large media stays in object storage.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Claim Check` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: Large files, large documents, media processing pipelines.
- কখন ব্যবহার করবেন না: Small মেসেজগুলো যেখানে extra storage round-trip adds unnecessary complexity.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"How would আপনি secure এবং expire claim-check references?\"
- রেড ফ্ল্যাগ: Sending huge blobs directly মাধ্যমে the কিউ/broker.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Claim Check`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- কোনো cleanup জন্য orphaned payload objects.
- Missing অথরাইজেশন checks on claim-check retrieval.
- না handling payload/version mismatch.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Sending huge blobs directly মাধ্যমে the কিউ/broker.
- কমন ভুল এড়ান: কোনো cleanup জন্য orphaned payload objects.
- Security টপিকে authn, authz, least privilege, logging - এই চারটা আলাদা করে বলুন।
- কেন দরকার (শর্ট নোট): মেসেজ brokers এবং APIs perform poorly সাথে very large payloads; large মেসেজগুলো এছাড়াও increase খরচ এবং রিট্রাই impact.
