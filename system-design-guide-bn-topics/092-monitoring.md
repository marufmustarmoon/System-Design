# Monitoring — বাংলা ব্যাখ্যা

_টপিক নম্বর: 092_

## গল্পে বুঝি

মন্টু মিয়াঁ শিখেছেন: production-এ “সমস্যা হলে দেখি” মানসিকতা কাজ করে না। আগে থেকে measurement, visibility, এবং alerting ডিজাইন করতে হয়।

`Monitoring` টপিকটি monitoring stack-এর একটি অংশ, যা incident detect, diagnose, and respond করতে সাহায্য করে।

Monitoring design-এ signal quality, cost, cardinality, false positives, এবং on-call usability গুরুত্বপূর্ণ।

ইন্টারভিউতে monitoring নিয়ে কথা বললে শুধু tool name না, decision-making utility বোঝান।

সহজ করে বললে `Monitoring` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: Monitoring is the practice of collecting signals about system health, পারফরম্যান্স, usage, and failures over time।

বাস্তব উদাহরণ ভাবতে চাইলে `Netflix, Google`-এর মতো সিস্টেমে `Monitoring`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Monitoring` আসলে কীভাবে সাহায্য করে?

`Monitoring` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- production visibility-কে metrics/logs/traces/alerts আকারে actionable signal-এ ভাঙতে সাহায্য করে।
- SLI/SLO signal, alert thresholds, ownership, আর runbook planning একসাথে discuss করতে সাহায্য করে।
- incident detect → diagnose → respond flow দ্রুত করার জন্য কোন telemetry দরকার তা পরিষ্কার করে।
- “dashboard আছে” বলার বদলে decision-support monitoring explain করতে সহায়তা করে।

---

### কখন `Monitoring` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → সবসময় জন্য production সিস্টেমগুলো; describe what আপনি will measure এবং alert on.
- Business value কোথায় বেশি? → আপনি পারে না operate অথবা উন্নত করতে ডিস্ট্রিবিউটেড সিস্টেম reliably ছাড়া visibility.
- কোন metrics/logs/traces সত্যিই business impact দেখায়?
- কোন alert actionable (owner + threshold + runbook) এবং কোনটা noise?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: করবেন না উপর-ইনডেক্স on vanity মেট্রিকস যা do না drive action.
- ইন্টারভিউ রেড ফ্ল্যাগ: কোনো mention of মনিটরিং, dashboards, অথবা অ্যালার্ট in a production architecture answer.
- মনিটরিং শুধু infrastructure মেট্রিকস এবং ignoring business/SLO মেট্রিকস.
- অ্যালার্টিং on everything (alert fatigue).
- কোনো runbook links অথবা ওনারশিপ জন্য অ্যালার্ট.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Monitoring` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

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

- `Monitoring` production visibility, alerting, diagnosis, এবং operational decision support-এর জন্য গুরুত্বপূর্ণ monitoring টপিক।
- এই টপিকে বারবার আসতে পারে: SLI/SLO, metrics/logs/traces, alerts, dashboards, incident response

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Monitoring` production system observe করার জন্য signal/telemetry/alerting design-এর গুরুত্বপূর্ণ ধারণা বোঝায়।

- মনিটরিং হলো the practice of collecting signals about সিস্টেম health, পারফরম্যান্স, usage, এবং ফেইলিউরগুলো উপর time.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: Production-এ সমস্যা নিজে থেকে ধরা পড়ে না; measurable signal, alerting, আর observability ছাড়া দ্রুত recovery কঠিন।

- আপনি পারে না operate অথবা উন্নত করতে ডিস্ট্রিবিউটেড সিস্টেম reliably ছাড়া visibility.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: SLI/SLO signal, actionable alerts, cardinality control, tracing context, আর on-call usability একসাথে design করতে হয়।

- Good মনিটরিং combines মেট্রিকস, logs, traces, ইভেন্টগুলো, এবং SLO-based অ্যালার্ট.
- মনিটরিং হলো না just dashboards; it should সাপোর্ট detection, diagnosis, এবং রেসপন্স.
- Interviewers value designs যা include observability from the start, না as an afterthought.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Monitoring` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Netflix** এবং **Google** rely on deep মনিটরিং to detect regressions, route around ফেইলিউরগুলো, এবং enforce SLOs.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Monitoring` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: সবসময় জন্য production সিস্টেমগুলো; describe what আপনি will measure এবং alert on.
- কখন ব্যবহার করবেন না: করবেন না উপর-ইনডেক্স on vanity মেট্রিকস যা do না drive action.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"What মেট্রিকস would আপনি monitor first জন্য এটি design?\"
- রেড ফ্ল্যাগ: কোনো mention of মনিটরিং, dashboards, অথবা অ্যালার্ট in a production architecture answer.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Monitoring`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- মনিটরিং শুধু infrastructure মেট্রিকস এবং ignoring business/SLO মেট্রিকস.
- অ্যালার্টিং on everything (alert fatigue).
- কোনো runbook links অথবা ওনারশিপ জন্য অ্যালার্ট.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: কোনো mention of মনিটরিং, dashboards, অথবা অ্যালার্ট in a production architecture answer.
- কমন ভুল এড়ান: মনিটরিং শুধু infrastructure মেট্রিকস এবং ignoring business/SLO মেট্রিকস.
- ইন্টারভিউতে কখন ব্যবহার করবেন/করবেন না - দুইটাই বললে উত্তরের মান বাড়ে।
- কেন দরকার (শর্ট নোট): আপনি পারে না operate অথবা উন্নত করতে ডিস্ট্রিবিউটেড সিস্টেম reliably ছাড়া visibility.
