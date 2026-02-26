# Throttling — বাংলা ব্যাখ্যা

_টপিক নম্বর: 140_

## গল্পে বুঝি

মন্টু মিয়াঁ `Throttling`-এর মতো resiliency pattern শেখেন কারণ distributed system-এ failure normal, exception না।

`Throttling` টপিকটা failure handle করার একটি নির্দিষ্ট কৌশল দেয় - সব failure-এ blind retry করলে অনেক সময় সমস্যা বাড়ে।

এই ধরনের pattern-এ context খুব গুরুত্বপূর্ণ: retryable vs non-retryable error, timeout budget, partial side effects, downstream overload, user experience।

ইন্টারভিউতে pattern নামের সাথে “কখন ব্যবহার করব না” বললে উত্তর অনেক শক্তিশালী হয়।

সহজ করে বললে `Throttling` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: Throttling limits request rates or resource usage to protect a system from overload।

বাস্তব উদাহরণ ভাবতে চাইলে `Amazon`-এর মতো সিস্টেমে `Throttling`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Throttling` আসলে কীভাবে সাহায্য করে?

`Throttling` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- failure scenario ধরে detection, isolation, recovery, আর fallback behavior design করতে সাহায্য করে।
- redundancy থাকলেই reliability solved না—এই operational reality স্পষ্ট করে।
- failover, retry, throttling, circuit breaking, degradation mode—কখন কোনটা ব্যবহার করবেন তা বোঝায়।
- RTO/RPO-like thinking, uptime target, আর cost trade-off discuss করতে সহায়তা করে।

---

### কখন `Throttling` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → Public APIs, shared সার্ভিসগুলো, dependency protection, multi-tenant fairness.
- Business value কোথায় বেশি? → Overload পারে cause cascading ফেইলিউরগুলো এবং lower overall অ্যাভেইলেবিলিটি জন্য everyone.
- failure domain কী: instance, AZ, region, dependency, deployment?
- failure detect করার signal কী, এবং automatic reaction কী হবে?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: করবেন না apply one hard limit জন্য all ক্লায়েন্টগুলো যদি priorities/SLAs differ.
- ইন্টারভিউ রেড ফ্ল্যাগ: কোনো throttling on public অথবা multi-tenant APIs.
- Global throttling শুধু, যা পারে punish healthy tenants.
- কোনো distinction মাঝে rate limits এবং concurrency limits.
- Returning vague errors ছাড়া রিট্রাই-পরে guidance.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Throttling` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

---

### মন্টুর কেস (ধাপে ধাপে)

- ধাপ ১: failure type classify করুন।
- ধাপ ২: pattern trigger condition ঠিক করুন।
- ধাপ ৩: state/side-effect safety (idempotency/compensation) নিশ্চিত করুন।
- ধাপ ৪: metrics/alerts দিয়ে behavior observe করুন।
- ধাপ ৫: misconfiguration হলে কী regression হবে তা বলুন।

---

### এই টপিকে মন্টু কী সিদ্ধান্ত নিচ্ছে?

- failure domain কী: instance, AZ, region, dependency, deployment?
- failure detect করার signal কী, এবং automatic reaction কী হবে?
- degrade mode, failover, retry, throttling - কোনটা কখন চালু হবে?

---

## এক লাইনে

- `Throttling` failure হলেও service continuity, recovery/failover behavior, এবং resilience trade-off design-এর টপিক।
- এই টপিকে বারবার আসতে পারে: rate limiting, load shedding, fairness, abuse protection, back pressure

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Throttling` failure handling, service continuity, failover/recovery behavior, এবং resilience design-এর মূল ধারণা বোঝায়।

- Throttling limits রিকোয়েস্ট rates অথবা resource usage to protect a সিস্টেম from overload.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: Failure normal ঘটনা; outage impact কমাতে আগেই detection, isolation, recovery, এবং fallback strategy দরকার।

- Overload পারে cause cascading ফেইলিউরগুলো এবং lower overall অ্যাভেইলেবিলিটি জন্য everyone.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: failure mode, detection signal, automatic reaction, degraded mode, এবং recovery trade-off একসাথে ব্যাখ্যা করলে senior insight বোঝায়।

- Throttling পারে হতে per-ইউজার, per-tenant, per-IP, per-endpoint, অথবা global, সাথে টোকেন bucket/leaky bucket অথবা concurrency limits.
- Good throttling preserves critical ট্রাফিক এবং communicates clear রিট্রাই guidance.
- Compare সাথে ব্যাক প্রেসার: throttling হলো a protective limit; ব্যাক প্রেসার হলো broader adaptive flow control জুড়ে সিস্টেম layers.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Throttling` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Amazon** APIs throttle abusive অথবা overly aggressive ক্লায়েন্টগুলো so checkout এবং catalog সার্ভিসগুলো stay healthy জন্য other ইউজাররা.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Throttling` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: Public APIs, shared সার্ভিসগুলো, dependency protection, multi-tenant fairness.
- কখন ব্যবহার করবেন না: করবেন না apply one hard limit জন্য all ক্লায়েন্টগুলো যদি priorities/SLAs differ.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"How would আপনি rate limit এবং communicate রিট্রাইগুলো to ক্লায়েন্টগুলো?\"
- রেড ফ্ল্যাগ: কোনো throttling on public অথবা multi-tenant APIs.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Throttling`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Global throttling শুধু, যা পারে punish healthy tenants.
- কোনো distinction মাঝে rate limits এবং concurrency limits.
- Returning vague errors ছাড়া রিট্রাই-পরে guidance.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: কোনো throttling on public অথবা multi-tenant APIs.
- কমন ভুল এড়ান: Global throttling শুধু, যা পারে punish healthy tenants.
- ইন্টারভিউতে কখন ব্যবহার করবেন/করবেন না - দুইটাই বললে উত্তরের মান বাড়ে।
- কেন দরকার (শর্ট নোট): Overload পারে cause cascading ফেইলিউরগুলো এবং lower overall অ্যাভেইলেবিলিটি জন্য everyone.
