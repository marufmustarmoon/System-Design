# Security Monitoring — বাংলা ব্যাখ্যা

_টপিক নম্বর: 096_

## গল্পে বুঝি

মন্টু মিয়াঁ login, admin action, token misuse, rate abuse - এসব signal আগে থেকে দেখতে চান, incident হওয়ার পরে না।

`Security Monitoring` টপিকটা suspicious activity detection, audit signals, auth failures, anomaly monitoring ইত্যাদি নিয়ে।

Security monitoring মানে শুধু logs জমা না; actionable detection + alert routing + investigation trail।

False positive ও blind spot - দুইটাই এখানে বড় design concern।

সহজ করে বললে `Security Monitoring` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: Security monitoring tracks suspicious activity, policy violations, and attack signals across applications and infrastructure।

বাস্তব উদাহরণ ভাবতে চাইলে `Google`-এর মতো সিস্টেমে `Security Monitoring`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Security Monitoring` আসলে কীভাবে সাহায্য করে?

`Security Monitoring` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- production visibility-কে metrics/logs/traces/alerts আকারে actionable signal-এ ভাঙতে সাহায্য করে।
- SLI/SLO signal, alert thresholds, ownership, আর runbook planning একসাথে discuss করতে সাহায্য করে।
- incident detect → diagnose → respond flow দ্রুত করার জন্য কোন telemetry দরকার তা পরিষ্কার করে।
- “dashboard আছে” বলার বদলে decision-support monitoring explain করতে সহায়তা করে।

---

### কখন `Security Monitoring` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → Any internet-facing সিস্টেম অথবা সিস্টেম handling sensitive ডেটা.
- Business value কোথায় বেশি? → Prevention controls fail; detection হলো required to respond quickly to abuse এবং breaches.
- কোন metrics/logs/traces সত্যিই business impact দেখায়?
- কোন alert actionable (owner + threshold + runbook) এবং কোনটা noise?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: করবেন না treat WAF/রেট লিমিটিং as a replacement জন্য সিকিউরিটি মনিটরিং.
- ইন্টারভিউ রেড ফ্ল্যাগ: কোনো অডিট লগিং জন্য auth/admin actions.
- লগিং sensitive ডেটা insecurely.
- অ্যালার্টিং on every failed login ছাড়া context.
- কোনো retention/access controls on সিকিউরিটি logs.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Security Monitoring` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

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

- `Security Monitoring` production visibility, alerting, diagnosis, এবং operational decision support-এর জন্য গুরুত্বপূর্ণ monitoring টপিক।
- এই টপিকে বারবার আসতে পারে: metrics/logs/traces, SLI/SLO, alerts, dashboards, runbooks

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Security Monitoring` production system observe করার জন্য signal/telemetry/alerting design-এর গুরুত্বপূর্ণ ধারণা বোঝায়।

- সিকিউরিটি মনিটরিং tracks suspicious activity, policy violations, এবং attack signals জুড়ে applications এবং infrastructure.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: Production-এ সমস্যা নিজে থেকে ধরা পড়ে না; measurable signal, alerting, আর observability ছাড়া দ্রুত recovery কঠিন।

- Prevention controls fail; detection হলো required to respond quickly to abuse এবং breaches.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: SLI/SLO signal, actionable alerts, cardinality control, tracing context, আর on-call usability একসাথে design করতে হয়।

- Signals include auth ফেইলিউরগুলো, unusual access patterns, privilege changes, rate anomalies, malware indicators, এবং অডিট logs.
- Effective সিকিউরিটি মনিটরিং balances detection coverage সাথে false-positive control এবং retention/compliance needs.
- এটি should হতে tied to incident রেসপন্স playbooks, না just logs stored somewhere.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Security Monitoring` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Google** monitors অথেন্টিকেশন anomalies এবং account abuse signals to protect ইউজার accounts এবং সার্ভিসগুলো.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Security Monitoring` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: Any internet-facing সিস্টেম অথবা সিস্টেম handling sensitive ডেটা.
- কখন ব্যবহার করবেন না: করবেন না treat WAF/রেট লিমিটিং as a replacement জন্য সিকিউরিটি মনিটরিং.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"What সিকিউরিটি ইভেন্টগুলো would আপনি log এবং alert on জন্য এটি design?\"
- রেড ফ্ল্যাগ: কোনো অডিট লগিং জন্য auth/admin actions.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Security Monitoring`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- লগিং sensitive ডেটা insecurely.
- অ্যালার্টিং on every failed login ছাড়া context.
- কোনো retention/access controls on সিকিউরিটি logs.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: কোনো অডিট লগিং জন্য auth/admin actions.
- কমন ভুল এড়ান: লগিং sensitive ডেটা insecurely.
- ইন্টারভিউতে কখন ব্যবহার করবেন/করবেন না - দুইটাই বললে উত্তরের মান বাড়ে।
- কেন দরকার (শর্ট নোট): Prevention controls fail; detection হলো required to respond quickly to abuse এবং breaches.
