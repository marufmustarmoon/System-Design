# High Availability — বাংলা ব্যাখ্যা

_টপিক নম্বর: 141_

## গল্পে বুঝি

মন্টু মিয়াঁর লক্ষ্য হলো failure হলেও পুরো service বন্ধ না হওয়া। কিন্তু redundancy যোগ করলেই reliability solve হয় না; failure detection আর recovery behavior equally গুরুত্বপূর্ণ।

`High Availability` টপিকটা reliability/availability design-এর এমন একটি অংশ যা outage impact কমাতে সাহায্য করে।

এখানে shared dependency, retry cascade, stale state, deployment mistakes - এগুলোও failure source হিসেবে ধরতে হয়।

ভালো answer-এ আপনি failure scenario + detection + recovery + trade-off একসাথে explain করবেন।

সহজ করে বললে `High Availability` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: High অ্যাভেইলেবিলিটি is the discipline of designing systems to meet very high uptime targets (often measured in nines) with minimal service interruption।

বাস্তব উদাহরণ ভাবতে চাইলে `Amazon`-এর মতো সিস্টেমে `High Availability`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `High Availability` আসলে কীভাবে সাহায্য করে?

`High Availability` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- uptime target, downtime budget, dependency failure, আর redundancy impact measurableভাবে explain করতে সাহায্য করে।
- redundancy থাকলেই reliability solved না—এই operational reality স্পষ্ট করে।
- failover, retry, throttling, circuit breaking, degradation mode—কখন কোনটা ব্যবহার করবেন তা বোঝায়।
- RTO/RPO-like thinking, uptime target, আর cost trade-off discuss করতে সহায়তা করে।

---

### কখন `High Availability` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → Critical paths সাথে strict SLO/SLA targets.
- Business value কোথায় বেশি? → Revenue-critical এবং mission-critical সিস্টেমগুলো পারে না tolerate long অথবা frequent outages.
- failure domain কী: instance, AZ, region, dependency, deployment?
- failure detect করার signal কী, এবং automatic reaction কী হবে?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: Low-value internal tools যেখানে HA খরচ/complexity হলো unjustified.
- ইন্টারভিউ রেড ফ্ল্যাগ: Claiming HA সাথে single-রিজিয়ন DB primary এবং manual failover.
- Equating HA সাথে multi-রিজিয়ন শুধু.
- Ignoring ডিপ্লয়মেন্ট-induced outages.
- কোনো regular failover drills অথবা game days.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `High Availability` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

---

### মন্টুর কেস (ধাপে ধাপে)

- ধাপ ১: failure domains identify করুন।
- ধাপ ২: detection signals নির্ধারণ করুন।
- ধাপ ৩: automatic/manual recovery path ডিজাইন করুন।
- ধাপ ৪: degradation/fallback policy বলুন।
- ধাপ ৫: testing/chaos drill/observability উল্লেখ করুন।

---

### এই টপিকে মন্টু কী সিদ্ধান্ত নিচ্ছে?

- failure domain কী: instance, AZ, region, dependency, deployment?
- failure detect করার signal কী, এবং automatic reaction কী হবে?
- degrade mode, failover, retry, throttling - কোনটা কখন চালু হবে?

---

## এক লাইনে

- `High Availability` failure হলেও service continuity, recovery/failover behavior, এবং resilience trade-off design-এর টপিক।
- এই টপিকে বারবার আসতে পারে: uptime target, downtime budget, failover, redundancy, dependency chain

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `High Availability` failure handling, service continuity, failover/recovery behavior, এবং resilience design-এর মূল ধারণা বোঝায়।

- হাই অ্যাভেইলেবিলিটি হলো the discipline of designing সিস্টেমগুলো to meet very high uptime targets (অনেক সময় measured in nines) সাথে minimal সার্ভিস interruption.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: Failure normal ঘটনা; outage impact কমাতে আগেই detection, isolation, recovery, এবং fallback strategy দরকার।

- Revenue-critical এবং mission-critical সিস্টেমগুলো পারে না tolerate long অথবা frequent outages.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: failure mode, detection signal, automatic reaction, degraded mode, এবং recovery trade-off একসাথে ব্যাখ্যা করলে senior insight বোঝায়।

- HA requires redundancy, fast detection, automated failover, safe ডিপ্লয়মেন্টগুলো, fault isolation, এবং dependency-aware design.
- এটি হলো না just more সার্ভারগুলো; operational automation এবং ফেইলিউর testing হলো essential.
- Compared সাথে general অ্যাভেইলেবিলিটি, HA demands tighter recovery objectives এবং stronger controls জন্য edge cases.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `High Availability` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Amazon** checkout-related সার্ভিসগুলো require HA কারণ even short outages have immediate business impact.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `High Availability` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: Critical paths সাথে strict SLO/SLA targets.
- কখন ব্যবহার করবেন না: Low-value internal tools যেখানে HA খরচ/complexity হলো unjustified.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"What changes move এটি design from basic অ্যাভেইলেবিলিটি to হাই অ্যাভেইলেবিলিটি?\"
- রেড ফ্ল্যাগ: Claiming HA সাথে single-রিজিয়ন DB primary এবং manual failover.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `High Availability`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Equating HA সাথে multi-রিজিয়ন শুধু.
- Ignoring ডিপ্লয়মেন্ট-induced outages.
- কোনো regular failover drills অথবা game days.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Claiming HA সাথে single-রিজিয়ন DB primary এবং manual failover.
- কমন ভুল এড়ান: Equating HA সাথে multi-রিজিয়ন শুধু.
- স্কেল/রিলায়েবিলিটি আলোচনায় traffic growth, failure case, আর cost একসাথে বলুন।
- কেন দরকার (শর্ট নোট): Revenue-critical এবং mission-critical সিস্টেমগুলো পারে না tolerate long অথবা frequent outages.
