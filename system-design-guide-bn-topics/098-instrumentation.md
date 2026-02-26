# Instrumentation — বাংলা ব্যাখ্যা

_টপিক নম্বর: 098_

## গল্পে বুঝি

মন্টু মিয়াঁ dashboard চান, কিন্তু data collect করার instrumentation না থাকলে dashboard ফাঁকা।

`Instrumentation` টপিকটা code/system-এ metrics/logs/traces emit করার নকশা নিয়ে।

ভুল instrumentation-এ high cardinality, missing context, noisy metrics, expensive logging সমস্যা হয়।

ভালো instrumentation downstream monitoring/alerting/troubleshooting-এর quality নির্ধারণ করে।

সহজ করে বললে `Instrumentation` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: Instrumentation is the code/config you add to emit metrics, logs, traces, and events from a system।

বাস্তব উদাহরণ ভাবতে চাইলে `Amazon`-এর মতো সিস্টেমে `Instrumentation`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Instrumentation` আসলে কীভাবে সাহায্য করে?

`Instrumentation` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- production visibility-কে metrics/logs/traces/alerts আকারে actionable signal-এ ভাঙতে সাহায্য করে।
- SLI/SLO signal, alert thresholds, ownership, আর runbook planning একসাথে discuss করতে সাহায্য করে।
- incident detect → diagnose → respond flow দ্রুত করার জন্য কোন telemetry দরকার তা পরিষ্কার করে।
- “dashboard আছে” বলার বদলে decision-support monitoring explain করতে সহায়তা করে।

---

### কখন `Instrumentation` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → At সার্ভিস boundaries, DB calls, কিউ handlers, এবং critical workflows.
- Business value কোথায় বেশি? → মনিটরিং সিস্টেমগুলো হলো শুধু as useful as the signals applications emit.
- কোন metrics/logs/traces সত্যিই business impact দেখায়?
- কোন alert actionable (owner + threshold + runbook) এবং কোনটা noise?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: করবেন না emit high-cardinality labels everywhere ছাড়া খরচ controls.
- ইন্টারভিউ রেড ফ্ল্যাগ: Saying "we’ll monitor it" ছাড়া describing what the সার্ভিস emits.
- লগিং unstructured text শুধু.
- Missing correlation IDs জুড়ে async boundaries.
- Instrumenting too late, পরে incidents happen.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Instrumentation` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

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

- `Instrumentation` production visibility, alerting, diagnosis, এবং operational decision support-এর জন্য গুরুত্বপূর্ণ monitoring টপিক।
- এই টপিকে বারবার আসতে পারে: telemetry signals, metric labels/cardinality, traces, correlation IDs, observability

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Instrumentation` production system observe করার জন্য signal/telemetry/alerting design-এর গুরুত্বপূর্ণ ধারণা বোঝায়।

- ইনস্ট্রুমেন্টেশন হলো the code/config আপনি add to emit মেট্রিকস, logs, traces, এবং ইভেন্টগুলো from a সিস্টেম.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: Production-এ সমস্যা নিজে থেকে ধরা পড়ে না; measurable signal, alerting, আর observability ছাড়া দ্রুত recovery কঠিন।

- মনিটরিং সিস্টেমগুলো হলো শুধু as useful as the signals applications emit.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: SLI/SLO signal, actionable alerts, cardinality control, tracing context, আর on-call usability একসাথে design করতে হয়।

- Good ইনস্ট্রুমেন্টেশন adds রিকোয়েস্ট IDs, correlation IDs, structured logs, spans, এবং business counters at key boundaries.
- এটি should হতে lightweight, consistent, এবং privacy-safe.
- Compare সাথে ভিজুয়ালাইজেশন: ইনস্ট্রুমেন্টেশন creates the ডেটা; ভিজুয়ালাইজেশন সাহায্য করে humans interpret it.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Instrumentation` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Amazon** সার্ভিসগুলো instrument রিকোয়েস্ট paths সাথে trace IDs so engineers পারে diagnose ল্যাটেন্সি জুড়ে multiple downstream সার্ভিসগুলো.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Instrumentation` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: At সার্ভিস boundaries, DB calls, কিউ handlers, এবং critical workflows.
- কখন ব্যবহার করবেন না: করবেন না emit high-cardinality labels everywhere ছাড়া খরচ controls.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"যেখানে would আপনি add tracing spans in এটি রিকোয়েস্ট path?\"
- রেড ফ্ল্যাগ: Saying "we’ll monitor it" ছাড়া describing what the সার্ভিস emits.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Instrumentation`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- লগিং unstructured text শুধু.
- Missing correlation IDs জুড়ে async boundaries.
- Instrumenting too late, পরে incidents happen.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Saying "we’ll monitor it" ছাড়া describing what the সার্ভিস emits.
- কমন ভুল এড়ান: লগিং unstructured text শুধু.
- ইন্টারভিউতে কখন ব্যবহার করবেন/করবেন না - দুইটাই বললে উত্তরের মান বাড়ে।
- কেন দরকার (শর্ট নোট): মনিটরিং সিস্টেমগুলো হলো শুধু as useful as the signals applications emit.
