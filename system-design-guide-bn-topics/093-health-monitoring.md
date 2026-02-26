# Health Monitoring — বাংলা ব্যাখ্যা

_টপিক নম্বর: 093_

## গল্পে বুঝি

মন্টু মিয়াঁ শুধু “server up” দেখে নিশ্চিন্ত থাকতে চান না; service আসলেই request serve করতে পারছে কি না সেটা জানতে চান।

`Health Monitoring` টপিকটা health signal/endpoint/checking strategy নিয়ে - যা failover, orchestration, and alerting-এর ভিত্তি হতে পারে।

Health check খুব shallow হলে false healthy দেখাতে পারে; খুব deep হলে noise বা dependency cascade তৈরি করতে পারে।

তাই liveness/readiness/deep health check আলাদা করে ভাবা জরুরি।

সহজ করে বললে `Health Monitoring` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: Health monitoring checks whether components are alive and able to serve traffic correctly।

বাস্তব উদাহরণ ভাবতে চাইলে `Amazon`-এর মতো সিস্টেমে `Health Monitoring`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Health Monitoring` আসলে কীভাবে সাহায্য করে?

`Health Monitoring` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- production visibility-কে metrics/logs/traces/alerts আকারে actionable signal-এ ভাঙতে সাহায্য করে।
- SLI/SLO signal, alert thresholds, ownership, আর runbook planning একসাথে discuss করতে সাহায্য করে।
- incident detect → diagnose → respond flow দ্রুত করার জন্য কোন telemetry দরকার তা পরিষ্কার করে।
- “dashboard আছে” বলার বদলে decision-support monitoring explain করতে সহায়তা করে।

---

### কখন `Health Monitoring` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → Any সার্ভিস behind a লোড balancer অথবা orchestrator.
- Business value কোথায় বেশি? → এটি drives লোড balancer routing, autoscaling decisions, এবং fast incident detection.
- কোন metrics/logs/traces সত্যিই business impact দেখায়?
- কোন alert actionable (owner + threshold + runbook) এবং কোনটা noise?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: করবেন না make হেলথ এন্ডপয়েন্টs depend on every downstream সার্ভিস unless আপনি want cascading removals.
- ইন্টারভিউ রেড ফ্ল্যাগ: ব্যবহার করে one হেলথ এন্ডপয়েন্ট জন্য both liveness এবং readiness সাথে identical logic.
- Returning 200 OK even যখন the সার্ভিস পারে না process real ট্রাফিক.
- Including slow dependencies in liveness checks.
- কোনো timeout on health probes.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Health Monitoring` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

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

- `Health Monitoring` production visibility, alerting, diagnosis, এবং operational decision support-এর জন্য গুরুত্বপূর্ণ monitoring টপিক।
- এই টপিকে বারবার আসতে পারে: metrics/logs/traces, SLI/SLO, alerts, dashboards, runbooks

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Health Monitoring` production system observe করার জন্য signal/telemetry/alerting design-এর গুরুত্বপূর্ণ ধারণা বোঝায়।

- Health মনিটরিং checks whether components হলো alive এবং able to serve ট্রাফিক correctly.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: Production-এ সমস্যা নিজে থেকে ধরা পড়ে না; measurable signal, alerting, আর observability ছাড়া দ্রুত recovery কঠিন।

- এটি drives লোড balancer routing, autoscaling decisions, এবং fast incident detection.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: SLI/SLO signal, actionable alerts, cardinality control, tracing context, আর on-call usability একসাথে design করতে হয়।

- হেলথ চেক should distinguish liveness (process alive) from readiness (safe to receive ট্রাফিক).
- Deep হেলথ চেক পারে catch dependency issues but may হতে expensive অথবা too noisy যদি overdone.
- Compare সাথে অ্যাভেইলেবিলিটি মনিটরিং: হেলথ চেক হলো component signals; অ্যাভেইলেবিলিটি মনিটরিং measures ইউজার-observed success.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Health Monitoring` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Amazon** লোড balancers ব্যবহার হেলথ এন্ডপয়েন্টs to stop routing ট্রাফিক to unhealthy application instances সময় ডিপ্লয়মেন্টগুলো.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Health Monitoring` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: Any সার্ভিস behind a লোড balancer অথবা orchestrator.
- কখন ব্যবহার করবেন না: করবেন না make হেলথ এন্ডপয়েন্টs depend on every downstream সার্ভিস unless আপনি want cascading removals.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"What should আপনার readiness check validate?\"
- রেড ফ্ল্যাগ: ব্যবহার করে one হেলথ এন্ডপয়েন্ট জন্য both liveness এবং readiness সাথে identical logic.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Health Monitoring`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Returning 200 OK even যখন the সার্ভিস পারে না process real ট্রাফিক.
- Including slow dependencies in liveness checks.
- কোনো timeout on health probes.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: ব্যবহার করে one হেলথ এন্ডপয়েন্ট জন্য both liveness এবং readiness সাথে identical logic.
- কমন ভুল এড়ান: Returning 200 OK even যখন the সার্ভিস পারে না process real ট্রাফিক.
- ইন্টারভিউতে কখন ব্যবহার করবেন/করবেন না - দুইটাই বললে উত্তরের মান বাড়ে।
- কেন দরকার (শর্ট নোট): এটি drives লোড balancer routing, autoscaling decisions, এবং fast incident detection.
