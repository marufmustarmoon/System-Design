# Back Pressure — বাংলা ব্যাখ্যা

_টপিক নম্বর: 069_

## গল্পে বুঝি

মন্টু মিয়াঁর producer service খুব দ্রুত message পাঠাচ্ছে, কিন্তু consumer ধীরে process করছে। কিউ লম্বা হচ্ছে, memory বাড়ছে, latency explode করছে।

`Back Pressure` টপিকটা producer-কে signal দিয়ে flow slow/downstream capacity-aware করার ধারণা।

Back pressure না থাকলে system দেখতে healthy হলেও sudden traffic-এ cascading failure হতে পারে।

এটা queue size, rate limit, pull-based consumption, bounded buffers, concurrency caps - নানা উপায়ে implement করা যায়।

সহজ করে বললে `Back Pressure` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: Back pressure is a mechanism to slow or limit producers when consumers or downstream systems cannot keep up।

বাস্তব উদাহরণ ভাবতে চাইলে `WhatsApp`-এর মতো সিস্টেমে `Back Pressure`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Back Pressure` আসলে কীভাবে সাহায্য করে?

`Back Pressure` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- producer rate আর downstream processing capacity mismatch হলে overload ঠেকাতে সাহায্য করে।
- queue lag, bounded buffers, throttling, concurrency limit—এই signals/actions design করতে সাহায্য করে।
- slow consumer-এর কারণে system-wide cascading failure কমায়।
- burst traffic-এর সময় graceful degradation strategy define করতে সহায়তা করে।

---

### কখন `Back Pressure` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → Streaming সিস্টেমগুলো, কিউগুলো, pipelines, any bursty async workload.
- Business value কোথায় বেশি? → ছাড়া it, কিউগুলো grow unbounded, ল্যাটেন্সি explodes, memory fills, এবং ফেইলিউরগুলো cascade.
- কোন কাজ sync থাকবে, কোন কাজ queue/event-এ যাবে?
- delivery guarantee কী: at-most-once, at-least-once, না idempotent retry সহ?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: করবেন না ignore it in high-থ্রুপুট pipelines এবং assume autoscaling reacts instantly.
- ইন্টারভিউ রেড ফ্ল্যাগ: Unlimited queueing সাথে no admission control.
- Treating bigger কিউগুলো as the শুধু solution.
- কোনো ইউজার-facing fallback যখন রিকোয়েস্টগুলো হলো slowed অথবা rejected.
- ব্যবহার করে one static threshold জন্য highly variable workloads.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Back Pressure` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

---

### মন্টুর কেস (ধাপে ধাপে)

- ধাপ ১: downstream capacity metric দেখুন (queue lag, consumer lag, memory, latency)।
- ধাপ ২: threshold cross হলে producer rate কমান বা reject/throttle করুন।
- ধাপ ৩: bounded queues/concurrency limit দিন।
- ধাপ ৪: retry storm avoid করতে jitter/backoff ব্যবহার করুন।
- ধাপ ৫: degraded mode policy নির্ধারণ করুন।

---

### এই টপিকে মন্টু কী সিদ্ধান্ত নিচ্ছে?

- কোন কাজ sync থাকবে, কোন কাজ queue/event-এ যাবে?
- delivery guarantee কী: at-most-once, at-least-once, না idempotent retry সহ?
- consumer slow হলে back pressure/DLQ/retry policy কীভাবে কাজ করবে?

---

## এক লাইনে

- `Back Pressure` downstream capacity কমে গেলে upstream producer/request rate নিয়ন্ত্রণ করে system overload ঠেকানোর টপিক।
- এই টপিকে বারবার আসতে পারে: queue lag, bounded buffers, producer throttling, consumer capacity, overload control

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Back Pressure` async workflow, queue/event contract, delivery behavior, এবং decoupling pattern বোঝার ভিত্তি দেয়।

- ব্যাক প্রেসার হলো a mechanism to slow অথবা limit প্রোডিউসারগুলো যখন কনজিউমারগুলো অথবা downstream সিস্টেমগুলো পারে না keep up.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: সব কাজ synchronous রাখলে request path ভারী হয়; async decoupling ও workload smoothing-এর জন্য messaging pattern দরকার।

- ছাড়া it, কিউগুলো grow unbounded, ল্যাটেন্সি explodes, memory fills, এবং ফেইলিউরগুলো cascade.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: delivery semantics, ordering, retries, idempotency, DLQ, এবং consumer lag/throughput behavior ব্যাখ্যা করা জরুরি।

- সিস্টেমগুলো signal pressure via কিউ depth, rate limits, window sizes, অথবা explicit credits/টোকেনগুলো.
- Good ব্যাক প্রেসার হলো proactive এবং layered (ক্লায়েন্ট, গেটওয়ে, worker, DB), না just "drop ট্রাফিক যখন broken."
- Compare সাথে simple throttling: throttling limits rate; ব্যাক প্রেসার adapts to downstream capacity in real time.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Back Pressure` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **WhatsApp** messaging infrastructure must control প্রোডিউসার rates যখন certain delivery paths অথবা media processing components হলো overloaded.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Back Pressure` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: Streaming সিস্টেমগুলো, কিউগুলো, pipelines, any bursty async workload.
- কখন ব্যবহার করবেন না: করবেন না ignore it in high-থ্রুপুট pipelines এবং assume autoscaling reacts instantly.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"What metric would আপনি ব্যবহার to trigger ব্যাক প্রেসার in আপনার কিউ workers?\"
- রেড ফ্ল্যাগ: Unlimited queueing সাথে no admission control.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Back Pressure`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Treating bigger কিউগুলো as the শুধু solution.
- কোনো ইউজার-facing fallback যখন রিকোয়েস্টগুলো হলো slowed অথবা rejected.
- ব্যবহার করে one static threshold জন্য highly variable workloads.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Unlimited queueing সাথে no admission control.
- কমন ভুল এড়ান: Treating bigger কিউগুলো as the শুধু solution.
- ইন্টারভিউতে কখন ব্যবহার করবেন/করবেন না - দুইটাই বললে উত্তরের মান বাড়ে।
- কেন দরকার (শর্ট নোট): ছাড়া it, কিউগুলো grow unbounded, ল্যাটেন্সি explodes, memory fills, এবং ফেইলিউরগুলো cascade.
