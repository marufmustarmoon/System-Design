# Circuit Breaker — বাংলা ব্যাখ্যা

_টপিক নম্বর: 149_

## গল্পে বুঝি

মন্টু মিয়াঁ `Circuit Breaker`-এর মতো resiliency pattern শেখেন কারণ distributed system-এ failure normal, exception না।

`Circuit Breaker` টপিকটা failure handle করার একটি নির্দিষ্ট কৌশল দেয় - সব failure-এ blind retry করলে অনেক সময় সমস্যা বাড়ে।

এই ধরনের pattern-এ context খুব গুরুত্বপূর্ণ: retryable vs non-retryable error, timeout budget, partial side effects, downstream overload, user experience।

ইন্টারভিউতে pattern নামের সাথে “কখন ব্যবহার করব না” বললে উত্তর অনেক শক্তিশালী হয়।

সহজ করে বললে `Circuit Breaker` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: In resiliency, circuit breakers help a service recover by failing fast against unhealthy dependencies and preventing repeated harm।

বাস্তব উদাহরণ ভাবতে চাইলে `Amazon`-এর মতো সিস্টেমে `Circuit Breaker`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Circuit Breaker` আসলে কীভাবে সাহায্য করে?

`Circuit Breaker` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- flaky downstream dependency-র সময় repeated failures থেকে cascading failure কমাতে সাহায্য করে।
- failure threshold, open/half-open/closed states, আর recovery probing behavior স্পষ্ট করে।
- retry + timeout + fallback policy একসাথে design করার ভিত্তি দেয়।
- system degrade mode-কে controlled ও observable রাখতে সাহায্য করে।

---

### কখন `Circuit Breaker` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → Dependencies সাথে known transient/persistent ফেইলিউরগুলো এবং expensive timeouts.
- Business value কোথায় বেশি? → Persistent downstream ফেইলিউরগুলো পারে exhaust resources এবং block recovery যদি every রিকোয়েস্ট keeps attempting the dependency.
- failure domain কী: instance, AZ, region, dependency, deployment?
- failure detect করার signal কী, এবং automatic reaction কী হবে?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: করবেন না wrap everything blindly ছাড়া understanding fallback semantics.
- ইন্টারভিউ রেড ফ্ল্যাগ: Open circuit returns generic 500 সাথে no graceful degradation plan.
- কোনো fallback অথবা cached রেসপন্স যখন circuit opens.
- Breaker thresholds based শুধু on count, না error rate/ল্যাটেন্সি window.
- Layering রিট্রাইগুলো inside/outside breakers incorrectly.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Circuit Breaker` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

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

- `Circuit Breaker` repeated downstream failure-এর সময় calls short-circuit করে cascading failure কমানোর resiliency pattern।
- এই টপিকে বারবার আসতে পারে: failure threshold, open/half-open/closed, cascading failure, fallback, downstream protection

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Circuit Breaker` failure handling, service continuity, failover/recovery behavior, এবং resilience design-এর মূল ধারণা বোঝায়।

- In resiliency, সার্কিট ব্রেকারs সাহায্য a সার্ভিস recover by failing fast against unhealthy dependencies এবং preventing repeated harm.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: Failure normal ঘটনা; outage impact কমাতে আগেই detection, isolation, recovery, এবং fallback strategy দরকার।

- Persistent downstream ফেইলিউরগুলো পারে exhaust resources এবং block recovery যদি every রিকোয়েস্ট keeps attempting the dependency.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: failure mode, detection signal, automatic reaction, degraded mode, এবং recovery trade-off একসাথে ব্যাখ্যা করলে senior insight বোঝায়।

- Breakers open যখন error/ল্যাটেন্সি thresholds হলো exceeded, then periodically test recovery in half-open mode.
- They pair সাথে fallback রেসপন্সগুলো, কিউগুলো, অথবা degraded modes to maintain ইউজার-facing behavior.
- Compared সাথে the HA section, এটি resilience framing emphasizes recovery pacing এবং dependency healing.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Circuit Breaker` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Amazon** product pages may temporarily omit non-critical recommendations যখন the recommendations সার্ভিস circuit হলো open.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Circuit Breaker` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: Dependencies সাথে known transient/persistent ফেইলিউরগুলো এবং expensive timeouts.
- কখন ব্যবহার করবেন না: করবেন না wrap everything blindly ছাড়া understanding fallback semantics.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"What should happen যখন the circuit opens এবং how do আপনি probe জন্য recovery?\"
- রেড ফ্ল্যাগ: Open circuit returns generic 500 সাথে no graceful degradation plan.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Circuit Breaker`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- কোনো fallback অথবা cached রেসপন্স যখন circuit opens.
- Breaker thresholds based শুধু on count, না error rate/ল্যাটেন্সি window.
- Layering রিট্রাইগুলো inside/outside breakers incorrectly.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Open circuit returns generic 500 সাথে no graceful degradation plan.
- কমন ভুল এড়ান: কোনো fallback অথবা cached রেসপন্স যখন circuit opens.
- স্কেল/রিলায়েবিলিটি আলোচনায় traffic growth, failure case, আর cost একসাথে বলুন।
- কেন দরকার (শর্ট নোট): Persistent downstream ফেইলিউরগুলো পারে exhaust resources এবং block recovery যদি every রিকোয়েস্ট keeps attempting the dependency.
