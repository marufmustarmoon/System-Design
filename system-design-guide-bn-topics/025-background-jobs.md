# Background Jobs — বাংলা ব্যাখ্যা

_টপিক নম্বর: 025_

## গল্পে বুঝি

মন্টু মিয়াঁর user ভিডিও আপলোড করতেই thumbnail, encoding, moderation, notification, analytics - অনেক কাজ শুরু হয়। সব কাজ request thread-এ করলে user waiting time বেড়ে যায়।

`Background Jobs` টপিকটা non-critical/slow কাজগুলো request path থেকে আলাদা করে worker/queue/async pipeline-এ নেওয়ার ধারণা।

এতে user দ্রুত response পায়, কিন্তু job tracking, retries, idempotency, status visibility, এবং failure recovery ডিজাইন করতে হয়।

“background job” মানে শুধু পরে করব না; মানে durable job creation + observable processing + clear result handling।

সহজ করে বললে `Background Jobs` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: Background jobs are tasks processed outside the user request path, usually asynchronously।

বাস্তব উদাহরণ ভাবতে চাইলে `YouTube`-এর মতো সিস্টেমে `Background Jobs`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Background Jobs` আসলে কীভাবে সাহায্য করে?

`Background Jobs` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- request path থেকে heavy/non-critical কাজ সরিয়ে user-facing latency কমাতে সাহায্য করে।
- job queue, worker retries, status tracking, আর failure recovery flow স্পষ্ট করতে সাহায্য করে।
- timeout-prone synchronous work-কে durable async processing-এ রূপান্তর করতে সহায়তা করে।
- “পরে করব” না বলে observable, retry-safe job processing design করতে সাহায্য করে।

---

### কখন `Background Jobs` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → Slow, retriable, অথবা non-ইউজার-blocking কাজ.
- Business value কোথায় বেশি? → Some কাজ হলো slow (emails, video encoding, report generation) এবং would make ইউজার-facing APIs too slow অথবা unreliable.
- কোন কাজ sync থাকবে, কোন কাজ queue/event-এ যাবে?
- delivery guarantee কী: at-most-once, at-least-once, না idempotent retry সহ?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: Operations যা must complete আগে ইউজার confirmation (যেমন, payment অথরাইজেশন) unless আপনি redesign UX carefully.
- ইন্টারভিউ রেড ফ্ল্যাগ: Offloading কাজ to ব্যাকগ্রাউন্ড জব ছাড়া defining রিট্রাই/idempotency behavior.
- Assuming async automatically মানে faster end-to-end completion.
- Forgetting মনিটরিং এবং dead-letter handling.
- Returning success আগে recording durable job intent.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Background Jobs` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

---

### মন্টুর কেস (ধাপে ধাপে)

- ধাপ ১: synchronous path থেকে slow কাজ আলাদা করুন।
- ধাপ ২: durable job record/queue message তৈরি করুন।
- ধাপ ৩: worker consume করে retry-safe processing চালাক।
- ধাপ ৪: job status/result lookup API বা callback model দিন।
- ধাপ ৫: timeout, retries, DLQ, cancellation policy যুক্ত করুন।

---

### এই টপিকে মন্টু কী সিদ্ধান্ত নিচ্ছে?

- কোন কাজ sync থাকবে, কোন কাজ queue/event-এ যাবে?
- delivery guarantee কী: at-most-once, at-least-once, না idempotent retry সহ?
- consumer slow হলে back pressure/DLQ/retry policy কীভাবে কাজ করবে?

---

## এক লাইনে

- `Background Jobs` request path থেকে slow/non-critical কাজ আলাদা করে async workers দিয়ে process করার design টপিক।
- এই টপিকে বারবার আসতে পারে: async processing, job queue, worker retries, job status, idempotent processing

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Background Jobs` async workflow, queue/event contract, delivery behavior, এবং decoupling pattern বোঝার ভিত্তি দেয়।

- ব্যাকগ্রাউন্ড জব হলো tasks processed outside the ইউজার রিকোয়েস্ট path, usually asynchronously.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: সব কাজ synchronous রাখলে request path ভারী হয়; async decoupling ও workload smoothing-এর জন্য messaging pattern দরকার।

- Some কাজ হলো slow (emails, video encoding, report generation) এবং would make ইউজার-facing APIs too slow অথবা unreliable.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: delivery semantics, ordering, retries, idempotency, DLQ, এবং consumer lag/throughput behavior ব্যাখ্যা করা জরুরি।

- এই রিকোয়েস্ট path stores intent, then workers process tasks via কিউগুলো অথবা schedulers.
- এটি উন্নত করে ল্যাটেন্সি এবং resiliency but introduces ইভেন্টুয়াল কনসিসটেন্সি, রিট্রাইগুলো, এবং duplicate execution concerns.
- এই key design question হলো what must happen synchronously vs what পারে happen later.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Background Jobs` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **YouTube** uploads return quickly যখন/একইসাথে transcoding, thumbnail generation, এবং moderation checks run as ব্যাকগ্রাউন্ড জব.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Background Jobs` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: Slow, retriable, অথবা non-ইউজার-blocking কাজ.
- কখন ব্যবহার করবেন না: Operations যা must complete আগে ইউজার confirmation (যেমন, payment অথরাইজেশন) unless আপনি redesign UX carefully.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"How do আপনি guarantee at-least-once processing ছাড়া double side effects?\"
- রেড ফ্ল্যাগ: Offloading কাজ to ব্যাকগ্রাউন্ড জব ছাড়া defining রিট্রাই/idempotency behavior.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Background Jobs`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Assuming async automatically মানে faster end-to-end completion.
- Forgetting মনিটরিং এবং dead-letter handling.
- Returning success আগে recording durable job intent.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Offloading কাজ to ব্যাকগ্রাউন্ড জব ছাড়া defining রিট্রাই/idempotency behavior.
- কমন ভুল এড়ান: Assuming async automatically মানে faster end-to-end completion.
- ইন্টারভিউতে কখন ব্যবহার করবেন/করবেন না - দুইটাই বললে উত্তরের মান বাড়ে।
- কেন দরকার (শর্ট নোট): Some কাজ হলো slow (emails, video encoding, report generation) এবং would make ইউজার-facing APIs too slow অথবা unreliable.
