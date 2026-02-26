# Usage Monitoring — বাংলা ব্যাখ্যা

_টপিক নম্বর: 097_

## গল্পে বুঝি

মন্টু মিয়াঁ product growth বুঝতে চান: কোন feature বেশি use হচ্ছে, কোথায় drop-off, কোন region-এ traffic surge।

`Usage Monitoring` টপিকটা system health না, product behavior ও adoption signal ধরার monitoring context।

Usage metrics capacity planning, pricing, feature prioritization, and abuse detection-এও কাজে লাগে।

তাই event schema quality, cardinality, privacy, and aggregation design গুরুত্বপূর্ণ।

সহজ করে বললে `Usage Monitoring` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: Usage monitoring tracks how features and APIs are used (traffic volume, user behavior, adoption, and usage patterns)।

বাস্তব উদাহরণ ভাবতে চাইলে `YouTube`-এর মতো সিস্টেমে `Usage Monitoring`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Usage Monitoring` আসলে কীভাবে সাহায্য করে?

`Usage Monitoring` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- production visibility-কে metrics/logs/traces/alerts আকারে actionable signal-এ ভাঙতে সাহায্য করে।
- SLI/SLO signal, alert thresholds, ownership, আর runbook planning একসাথে discuss করতে সাহায্য করে।
- incident detect → diagnose → respond flow দ্রুত করার জন্য কোন telemetry দরকার তা পরিষ্কার করে।
- “dashboard আছে” বলার বদলে decision-support monitoring explain করতে সহায়তা করে।

---

### কখন `Usage Monitoring` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → Capacity planning, pricing models, product prioritization, anomaly detection.
- Business value কোথায় বেশি? → Capacity planning, product decisions, এবং abuse detection all depend on usage visibility.
- কোন metrics/logs/traces সত্যিই business impact দেখায়?
- কোন alert actionable (owner + threshold + runbook) এবং কোনটা noise?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: করবেন না capture more ইউজার ডেটা than necessary অথবা ছাড়া privacy controls.
- ইন্টারভিউ রেড ফ্ল্যাগ: কোনো per-tenant অথবা per-feature visibility in a multi-tenant সিস্টেম.
- Mixing product analytics এবং operational মেট্রিকস সাথে no ওনারশিপ.
- Ignoring cardinality খরচ in মেট্রিকস সিস্টেমগুলো.
- Tracking vanity মেট্রিকস যা do না affect decisions.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Usage Monitoring` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

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

- `Usage Monitoring` production visibility, alerting, diagnosis, এবং operational decision support-এর জন্য গুরুত্বপূর্ণ monitoring টপিক।
- এই টপিকে বারবার আসতে পারে: metrics/logs/traces, SLI/SLO, alerts, dashboards, runbooks

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Usage Monitoring` production system observe করার জন্য signal/telemetry/alerting design-এর গুরুত্বপূর্ণ ধারণা বোঝায়।

- Usage মনিটরিং tracks how features এবং APIs হলো used (ট্রাফিক volume, ইউজার behavior, adoption, এবং usage patterns).

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: Production-এ সমস্যা নিজে থেকে ধরা পড়ে না; measurable signal, alerting, আর observability ছাড়া দ্রুত recovery কঠিন।

- Capacity planning, product decisions, এবং abuse detection all depend on usage visibility.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: SLI/SLO signal, actionable alerts, cardinality control, tracing context, আর on-call usability একসাথে design করতে হয়।

- Collect per-endpoint/feature মেট্রিকস, tenant/ইউজার segmentation, এবং growth trends.
- Usage মেট্রিকস should হতে defined carefully to এড়াতে double counting এবং to preserve privacy.
- Compared সাথে পারফরম্যান্স মনিটরিং, usage ডেটা explains demand shape এবং business value, না just technical speed.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Usage Monitoring` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **YouTube** tracks feature usage এবং watch behavior মেট্রিকস to guide product decisions এবং capacity planning.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Usage Monitoring` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: Capacity planning, pricing models, product prioritization, anomaly detection.
- কখন ব্যবহার করবেন না: করবেন না capture more ইউজার ডেটা than necessary অথবা ছাড়া privacy controls.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"What usage মেট্রিকস would influence আপনার স্কেলিং decisions?\"
- রেড ফ্ল্যাগ: কোনো per-tenant অথবা per-feature visibility in a multi-tenant সিস্টেম.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Usage Monitoring`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Mixing product analytics এবং operational মেট্রিকস সাথে no ওনারশিপ.
- Ignoring cardinality খরচ in মেট্রিকস সিস্টেমগুলো.
- Tracking vanity মেট্রিকস যা do না affect decisions.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: কোনো per-tenant অথবা per-feature visibility in a multi-tenant সিস্টেম.
- কমন ভুল এড়ান: Mixing product analytics এবং operational মেট্রিকস সাথে no ওনারশিপ.
- ইন্টারভিউতে কখন ব্যবহার করবেন/করবেন না - দুইটাই বললে উত্তরের মান বাড়ে।
- কেন দরকার (শর্ট নোট): Capacity planning, product decisions, এবং abuse detection all depend on usage visibility.
