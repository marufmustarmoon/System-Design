# Performance Monitoring — বাংলা ব্যাখ্যা

_টপিক নম্বর: 095_

## গল্পে বুঝি

মন্টু মিয়াঁর app “up” আছে, কিন্তু slow। user complaint কমাতে availability-এর সাথে performance visibility-ও দরকার।

`Performance Monitoring` টপিকটা latency, throughput, error rate, saturation, tail latency, and hotspot detection নিয়ে।

Performance monitoring না থাকলে capacity planning ও bottleneck diagnosis guesswork হয়ে যায়।

ইন্টারভিউতে p50/p95/p99, per-endpoint metrics, dependency latency breakdown mention করলে answer realistic লাগে।

সহজ করে বললে `Performance Monitoring` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: Performance monitoring tracks ল্যাটেন্সি, থ্রুপুট, saturation, and resource usage to understand system behavior under load।

বাস্তব উদাহরণ ভাবতে চাইলে `Uber`-এর মতো সিস্টেমে `Performance Monitoring`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Performance Monitoring` আসলে কীভাবে সাহায্য করে?

`Performance Monitoring` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- production visibility-কে metrics/logs/traces/alerts আকারে actionable signal-এ ভাঙতে সাহায্য করে।
- SLI/SLO signal, alert thresholds, ownership, আর runbook planning একসাথে discuss করতে সাহায্য করে।
- incident detect → diagnose → respond flow দ্রুত করার জন্য কোন telemetry দরকার তা পরিষ্কার করে।
- “dashboard আছে” বলার বদলে decision-support monitoring explain করতে সহায়তা করে।

---

### কখন `Performance Monitoring` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → সবসময় in production; especially যখন discussing bottlenecks এবং স্কেলিং triggers.
- Business value কোথায় বেশি? → Slow সিস্টেমগুলো পারে appear "available" but still fail ইউজার expectations এবং SLOs.
- কোন metrics/logs/traces সত্যিই business impact দেখায়?
- কোন alert actionable (owner + threshold + runbook) এবং কোনটা noise?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: করবেন না focus on averages শুধু জন্য ইউজার-facing সিস্টেমগুলো.
- ইন্টারভিউ রেড ফ্ল্যাগ: কোনো p95/p99 মেট্রিকস in a ল্যাটেন্সি-sensitive design.
- মনিটরিং শুধু host মেট্রিকস এবং না endpoint-level ল্যাটেন্সি.
- কোনো breakdown by route/tenant/রিজিয়ন.
- না correlating পারফরম্যান্স drops সাথে deploys অথবা ট্রাফিক shifts.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Performance Monitoring` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

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

- `Performance Monitoring` production visibility, alerting, diagnosis, এবং operational decision support-এর জন্য গুরুত্বপূর্ণ monitoring টপিক।
- এই টপিকে বারবার আসতে পারে: metrics/logs/traces, SLI/SLO, alerts, dashboards, runbooks

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Performance Monitoring` production system observe করার জন্য signal/telemetry/alerting design-এর গুরুত্বপূর্ণ ধারণা বোঝায়।

- পারফরম্যান্স মনিটরিং tracks ল্যাটেন্সি, থ্রুপুট, saturation, এবং resource usage to understand সিস্টেম behavior এর অধীনে লোড.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: Production-এ সমস্যা নিজে থেকে ধরা পড়ে না; measurable signal, alerting, আর observability ছাড়া দ্রুত recovery কঠিন।

- Slow সিস্টেমগুলো পারে appear "available" but still fail ইউজার expectations এবং SLOs.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: SLI/SLO signal, actionable alerts, cardinality control, tracing context, আর on-call usability একসাথে design করতে হয়।

- Key signals include p50/p95/p99 ল্যাটেন্সি, রিকোয়েস্ট rates, কিউ depth, CPU, memory, DB ল্যাটেন্সি, এবং downstream timings.
- Tracing সাহায্য করে identify যা dependency causes tail ল্যাটেন্সি.
- Compare সাথে usage মনিটরিং: পারফরম্যান্স মনিটরিং asks "how fast এবং stable?" যখন/একইসাথে usage মনিটরিং asks "how much এবং by whom?"

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Performance Monitoring` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Uber** monitors p99 dispatch এবং trip API ল্যাটেন্সি সময় surge periods to protect rider/driver UX.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Performance Monitoring` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: সবসময় in production; especially যখন discussing bottlenecks এবং স্কেলিং triggers.
- কখন ব্যবহার করবেন না: করবেন না focus on averages শুধু জন্য ইউজার-facing সিস্টেমগুলো.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"যা ল্যাটেন্সি percentiles would আপনি track এবং why?\"
- রেড ফ্ল্যাগ: কোনো p95/p99 মেট্রিকস in a ল্যাটেন্সি-sensitive design.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Performance Monitoring`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- মনিটরিং শুধু host মেট্রিকস এবং না endpoint-level ল্যাটেন্সি.
- কোনো breakdown by route/tenant/রিজিয়ন.
- না correlating পারফরম্যান্স drops সাথে deploys অথবা ট্রাফিক shifts.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: কোনো p95/p99 মেট্রিকস in a ল্যাটেন্সি-sensitive design.
- কমন ভুল এড়ান: মনিটরিং শুধু host মেট্রিকস এবং না endpoint-level ল্যাটেন্সি.
- ইন্টারভিউতে কখন ব্যবহার করবেন/করবেন না - দুইটাই বললে উত্তরের মান বাড়ে।
- কেন দরকার (শর্ট নোট): Slow সিস্টেমগুলো পারে appear "available" but still fail ইউজার expectations এবং SLOs.
