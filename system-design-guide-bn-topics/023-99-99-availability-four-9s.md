# 99.99% Availability (Four 9s) — বাংলা ব্যাখ্যা

_টপিক নম্বর: 023_

## গল্পে বুঝি

মন্টু মিয়াঁ “high availability” শুনে খুশি, কিন্তু business team জিজ্ঞেস করল: বছরে ঠিক কত downtime tolerate করা যাবে? তখন percent availability-কে বাস্তব মিনিট/ঘণ্টায় রূপান্তর করা দরকার হলো।

`99.99% Availability (Four 9s)` টপিকটা availability-কে measurableভাবে ভাবতে শেখায় - শুধু qualitative statement না।

এখানে dependency composition (series vs parallel), maintenance window, failover time, and monitoring accuracy availability outcome-এ প্রভাব ফেলে।

ইন্টারভিউতে numbers বললে design trade-off বাস্তবসম্মত লাগে, especially cost vs uptime discussion-এ।

সহজ করে বললে `99.99% Availability (Four 9s)` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: 99.99% অ্যাভেইলেবিলিটি means about 0.01% downtime is allowed।

বাস্তব উদাহরণ ভাবতে চাইলে `Amazon`-এর মতো সিস্টেমে `99.99% Availability (Four 9s)`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `99.99% Availability (Four 9s)` আসলে কীভাবে সাহায্য করে?

`99.99% Availability (Four 9s)` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- uptime target, downtime budget, dependency failure, আর redundancy impact measurableভাবে explain করতে সাহায্য করে।
- redundancy থাকলেই reliability solved না—এই operational reality স্পষ্ট করে।
- failover, retry, throttling, circuit breaking, degradation mode—কখন কোনটা ব্যবহার করবেন তা বোঝায়।
- RTO/RPO-like thinking, uptime target, আর cost trade-off discuss করতে সহায়তা করে।

---

### কখন `99.99% Availability (Four 9s)` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → Revenue-critical APIs, অথেন্টিকেশন, checkout, messaging delivery control plane.
- Business value কোথায় বেশি? → Critical ইউজার-facing সিস্টেমগুলো need very short outages to protect revenue, trust, অথবা safety.
- failure domain কী: instance, AZ, region, dependency, deployment?
- failure detect করার signal কী, এবং automatic reaction কী হবে?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: Low-value batch jobs যেখানে the খরচ of achieving four 9s outweighs business value.
- ইন্টারভিউ রেড ফ্ল্যাগ: Proposing four 9s যখন/একইসাথে keeping manual failover এবং no observability.
- Thinking adding one more replica হলো enough.
- Forgetting ডিপ্লয়মেন্ট-related outages হলো a major source of downtime.
- Ignoring dependency contracts এবং shared infrastructure limits.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `99.99% Availability (Four 9s)` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

---

### মন্টুর কেস (ধাপে ধাপে)

- ধাপ ১: target availability/SLO নির্ধারণ করুন।
- ধাপ ২: downtime budget-এ convert করুন (মাস/বছর হিসেবে)।
- ধাপ ৩: dependency chain series/parallel impact হিসাব করুন।
- ধাপ ৪: redundancy/failover investment কোথায় দরকার ঠিক করুন।
- ধাপ ৫: measured availability কীভাবে monitor/report করবেন তা বলুন।

---

### এই টপিকে মন্টু কী সিদ্ধান্ত নিচ্ছে?

- failure domain কী: instance, AZ, region, dependency, deployment?
- failure detect করার signal কী, এবং automatic reaction কী হবে?
- degrade mode, failover, retry, throttling - কোনটা কখন চালু হবে?

---

## এক লাইনে

- `99.99% Availability (Four 9s)` failure হলেও service continuity, recovery/failover behavior, এবং resilience trade-off design-এর টপিক।
- এই টপিকে বারবার আসতে পারে: uptime target, downtime budget, failover, redundancy, dependency chain

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `99.99% Availability (Four 9s)` failure handling, service continuity, failover/recovery behavior, এবং resilience design-এর মূল ধারণা বোঝায়।

- 99.99% অ্যাভেইলেবিলিটি মানে about 0.01% downtime হলো allowed.
- Roughly, যা হলো about 4.3 minutes per month.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: Failure normal ঘটনা; outage impact কমাতে আগেই detection, isolation, recovery, এবং fallback strategy দরকার।

- Critical ইউজার-facing সিস্টেমগুলো need very short outages to protect revenue, trust, অথবা safety.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: failure mode, detection signal, automatic reaction, degraded mode, এবং recovery trade-off একসাথে ব্যাখ্যা করলে senior insight বোঝায়।

- Four 9s usually requires stronger automation, faster detection, safer ডিপ্লয়মেন্টগুলো, এবং blast-radius control.
- Single points of ফেইলিউর become unacceptable, including operational processes (manual runbooks, human approvals).
- Compared সাথে three 9s, খরচ এবং complexity rise sharply জন্য diminishing percentage gains.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `99.99% Availability (Four 9s)` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Amazon** checkout এবং payment-adjacent paths aim জন্য very হাই অ্যাভেইলেবিলিটি কারণ downtime directly impacts revenue.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `99.99% Availability (Four 9s)` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: Revenue-critical APIs, অথেন্টিকেশন, checkout, messaging delivery control plane.
- কখন ব্যবহার করবেন না: Low-value batch jobs যেখানে the খরচ of achieving four 9s outweighs business value.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"যা components হলো most likely to block four-9s অ্যাভেইলেবিলিটি in আপনার design?\"
- রেড ফ্ল্যাগ: Proposing four 9s যখন/একইসাথে keeping manual failover এবং no observability.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `99.99% Availability (Four 9s)`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Thinking adding one more replica হলো enough.
- Forgetting ডিপ্লয়মেন্ট-related outages হলো a major source of downtime.
- Ignoring dependency contracts এবং shared infrastructure limits.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Proposing four 9s যখন/একইসাথে keeping manual failover এবং no observability.
- কমন ভুল এড়ান: Thinking adding one more replica হলো enough.
- স্কেল/রিলায়েবিলিটি আলোচনায় traffic growth, failure case, আর cost একসাথে বলুন।
- কেন দরকার (শর্ট নোট): Critical ইউজার-facing সিস্টেমগুলো need very short outages to protect revenue, trust, অথবা safety.
