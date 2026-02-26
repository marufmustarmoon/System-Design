# Availability in Numbers — বাংলা ব্যাখ্যা

_টপিক নম্বর: 021_

## গল্পে বুঝি

মন্টু মিয়াঁ “high availability” শুনে খুশি, কিন্তু business team জিজ্ঞেস করল: বছরে ঠিক কত downtime tolerate করা যাবে? তখন percent availability-কে বাস্তব মিনিট/ঘণ্টায় রূপান্তর করা দরকার হলো।

`Availability in Numbers` টপিকটা availability-কে measurableভাবে ভাবতে শেখায় - শুধু qualitative statement না।

এখানে dependency composition (series vs parallel), maintenance window, failover time, and monitoring accuracy availability outcome-এ প্রভাব ফেলে।

ইন্টারভিউতে numbers বললে design trade-off বাস্তবসম্মত লাগে, especially cost vs uptime discussion-এ।

সহজ করে বললে `Availability in Numbers` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: Availability in numbers translates uptime goals (like 99.9%) into allowed downtime over a period।

বাস্তব উদাহরণ ভাবতে চাইলে `Netflix`-এর মতো সিস্টেমে `Availability in Numbers`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Availability in Numbers` আসলে কীভাবে সাহায্য করে?

`Availability in Numbers` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- uptime target, downtime budget, dependency failure, আর redundancy impact measurableভাবে explain করতে সাহায্য করে।
- redundancy থাকলেই reliability solved না—এই operational reality স্পষ্ট করে।
- failover, retry, throttling, circuit breaking, degradation mode—কখন কোনটা ব্যবহার করবেন তা বোঝায়।
- RTO/RPO-like thinking, uptime target, আর cost trade-off discuss করতে সহায়তা করে।

---

### কখন `Availability in Numbers` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → যখন discussing SLOs, SLAs, এবং architecture খরচ/complexity ট্রেড-অফ.
- Business value কোথায় বেশি? → টিমগুলো need measurable SLO targets, না vague claims like "highly available."
- failure domain কী: instance, AZ, region, dependency, deployment?
- failure detect করার signal কী, এবং automatic reaction কী হবে?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: করবেন না throw "five 9s" into every design ছাড়া business justification.
- ইন্টারভিউ রেড ফ্ল্যাগ: Quoting uptime percentages ছাড়া defining measurement scope.
- Confusing SLA (contract) সাথে SLO (engineering target).
- Ignoring planned maintenance এবং degraded সার্ভিস definitions.
- Treating global uptime as a single number ছাড়া endpoint-level detail.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Availability in Numbers` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

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

- `Availability in Numbers` failure হলেও service continuity, recovery/failover behavior, এবং resilience trade-off design-এর টপিক।
- এই টপিকে বারবার আসতে পারে: uptime target, downtime budget, failover, redundancy, dependency chain

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Availability in Numbers` failure handling, service continuity, failover/recovery behavior, এবং resilience design-এর মূল ধারণা বোঝায়।

- অ্যাভেইলেবিলিটি in numbers translates uptime goals (like 99.9%) into allowed downtime উপর a period.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: Failure normal ঘটনা; outage impact কমাতে আগেই detection, isolation, recovery, এবং fallback strategy দরকার।

- টিমগুলো need measurable SLO targets, না vague claims like "highly available."
- এটি সাহায্য করে align architecture খরচ সাথে business impact.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: failure mode, detection signal, automatic reaction, degraded mode, এবং recovery trade-off একসাথে ব্যাখ্যা করলে senior insight বোঝায়।

- এই extra "9" looks small but হলো expensive কারণ it requires reducing rare edge-case ফেইলিউরগুলো এবং faster recovery.
- অ্যাভেইলেবিলিটি must হতে defined clearly: what endpoint, what রিজিয়ন, what error threshold, এবং what time window.
- Interviewers like যখন আপনি connect target অ্যাভেইলেবিলিটি to concrete design choices (redundancy, failover, rollback, observability).

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Availability in Numbers` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Netflix** may set stricter অ্যাভেইলেবিলিটি goals জন্য playback APIs than জন্য non-critical admin tooling.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Availability in Numbers` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: যখন discussing SLOs, SLAs, এবং architecture খরচ/complexity ট্রেড-অফ.
- কখন ব্যবহার করবেন না: করবেন না throw "five 9s" into every design ছাড়া business justification.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"What does 99.9% অ্যাভেইলেবিলিটি mean in minutes of downtime per month?\"
- রেড ফ্ল্যাগ: Quoting uptime percentages ছাড়া defining measurement scope.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Availability in Numbers`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Confusing SLA (contract) সাথে SLO (engineering target).
- Ignoring planned maintenance এবং degraded সার্ভিস definitions.
- Treating global uptime as a single number ছাড়া endpoint-level detail.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Quoting uptime percentages ছাড়া defining measurement scope.
- কমন ভুল এড়ান: Confusing SLA (contract) সাথে SLO (engineering target).
- স্কেল/রিলায়েবিলিটি আলোচনায় traffic growth, failure case, আর cost একসাথে বলুন।
- কেন দরকার (শর্ট নোট): টিমগুলো need measurable SLO targets, না vague claims like "highly available."
