# Availability Monitoring — বাংলা ব্যাখ্যা

_টপিক নম্বর: 094_

## গল্পে বুঝি

মন্টু মিয়াঁ জানতে চান user perspective থেকে service কতটা reachable ও successful। শুধু CPU metrics দেখে availability বোঝা যায় না।

`Availability Monitoring` টপিকে success rate, synthetic checks, endpoint health, SLA/SLO signal-এর মতো ধারণা আসে।

এখানে monitoring design business impact-এর সাথে যুক্ত: কোন endpoint down হলে revenue/user experience কতটা প্রভাবিত হচ্ছে।

ভালো availability monitoring-এ internal metrics + external probing দুইটাই থাকে।

সহজ করে বললে `Availability Monitoring` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: Availability monitoring measures whether the system is actually serving successful requests to users (or synthetic clients)।

বাস্তব উদাহরণ ভাবতে চাইলে `Netflix`-এর মতো সিস্টেমে `Availability Monitoring`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Availability Monitoring` আসলে কীভাবে সাহায্য করে?

`Availability Monitoring` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- production visibility-কে metrics/logs/traces/alerts আকারে actionable signal-এ ভাঙতে সাহায্য করে।
- SLI/SLO signal, alert thresholds, ownership, আর runbook planning একসাথে discuss করতে সাহায্য করে।
- incident detect → diagnose → respond flow দ্রুত করার জন্য কোন telemetry দরকার তা পরিষ্কার করে।
- “dashboard আছে” বলার বদলে decision-support monitoring explain করতে সহায়তা করে।

---

### কখন `Availability Monitoring` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → SLOs, uptime reporting, incident detection, customer-facing reliability.
- Business value কোথায় বেশি? → একটি সার্ভিস পারে হতে "up" by হেলথ চেক যখন/একইসাথে ইউজাররা still experience ফেইলিউরগুলো.
- কোন metrics/logs/traces সত্যিই business impact দেখায়?
- কোন alert actionable (owner + threshold + runbook) এবং কোনটা noise?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: করবেন না rely শুধু on internal মেট্রিকস যদি আপনি need external ইউজার-impact visibility.
- ইন্টারভিউ রেড ফ্ল্যাগ: Measuring অ্যাভেইলেবিলিটি শুধু by CPU অথবা instance counts.
- Counting all endpoints equally যখন শুধু a few drive ইউজার value.
- কোনো synthetic মনিটরিং from multiple রিজিয়নগুলো.
- Confusing transient ল্যাটেন্সি spikes সাথে outright অ্যাভেইলেবিলিটি ফেইলিউরগুলো.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Availability Monitoring` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

---

### মন্টুর কেস (ধাপে ধাপে)

- ধাপ ১: critical user journeys এবং SLIs identify করুন।
- ধাপ ২: metrics/logs/traces instrumentation নিশ্চিত করুন।
- ধাপ ৩: dashboards ও alert rules set করুন।
- ধাপ ৪: alert ownership + runbook define করুন।
- ধাপ ৫: incidents থেকে monitoring gap feedback loop চালান।

---

### এই টপিকে মন্টু কী সিদ্ধান্ত নিচ্ছে?

- কোন metrics/logs/traces সত্যিই business impact দেখায়?
- কোন alert actionable (owner + threshold + runbook) এবং কোনটা noise?
- incident হলে এই signal থেকে কত দ্রুত root cause narrow down করা যাবে?

---

## এক লাইনে

- `Availability Monitoring` production visibility, alerting, diagnosis, এবং operational decision support-এর জন্য গুরুত্বপূর্ণ monitoring টপিক।
- এই টপিকে বারবার আসতে পারে: uptime target, downtime budget, failover, redundancy, dependency chain

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Availability Monitoring` production system observe করার জন্য signal/telemetry/alerting design-এর গুরুত্বপূর্ণ ধারণা বোঝায়।

- অ্যাভেইলেবিলিটি মনিটরিং measures whether the সিস্টেম হলো actually serving successful রিকোয়েস্টগুলো to ইউজাররা (অথবা synthetic ক্লায়েন্টগুলো).

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: Production-এ সমস্যা নিজে থেকে ধরা পড়ে না; measurable signal, alerting, আর observability ছাড়া দ্রুত recovery কঠিন।

- একটি সার্ভিস পারে হতে "up" by হেলথ চেক যখন/একইসাথে ইউজাররা still experience ফেইলিউরগুলো.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: SLI/SLO signal, actionable alerts, cardinality control, tracing context, আর on-call usability একসাথে design করতে হয়।

- এটি ব্যবহার করে SLI মেট্রিকস like success rate, error rate, এবং synthetic probes জুড়ে রিজিয়নগুলো.
- অ্যাভেইলেবিলিটি should হতে measured at ইউজার-critical endpoints, না just instance status.
- Compared সাথে health মনিটরিং, অ্যাভেইলেবিলিটি মনিটরিং reflects ইউজার impact এবং SLO compliance.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Availability Monitoring` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Netflix** tracks playback start success এবং API success rates কারণ সার্ভার process health alone does না capture ইউজার অ্যাভেইলেবিলিটি.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Availability Monitoring` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: SLOs, uptime reporting, incident detection, customer-facing reliability.
- কখন ব্যবহার করবেন না: করবেন না rely শুধু on internal মেট্রিকস যদি আপনি need external ইউজার-impact visibility.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"What SLI would আপনি ব্যবহার to measure অ্যাভেইলেবিলিটি জন্য এটি সিস্টেম?\"
- রেড ফ্ল্যাগ: Measuring অ্যাভেইলেবিলিটি শুধু by CPU অথবা instance counts.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Availability Monitoring`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Counting all endpoints equally যখন শুধু a few drive ইউজার value.
- কোনো synthetic মনিটরিং from multiple রিজিয়নগুলো.
- Confusing transient ল্যাটেন্সি spikes সাথে outright অ্যাভেইলেবিলিটি ফেইলিউরগুলো.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Measuring অ্যাভেইলেবিলিটি শুধু by CPU অথবা instance counts.
- কমন ভুল এড়ান: Counting all endpoints equally যখন শুধু a few drive ইউজার value.
- ইন্টারভিউতে কখন ব্যবহার করবেন/করবেন না - দুইটাই বললে উত্তরের মান বাড়ে।
- কেন দরকার (শর্ট নোট): একটি সার্ভিস পারে হতে "up" by হেলথ চেক যখন/একইসাথে ইউজাররা still experience ফেইলিউরগুলো.
