# Fail-Over — বাংলা ব্যাখ্যা

_টপিক নম্বর: 015_

## গল্পে বুঝি

মন্টু মিয়াঁর primary server নষ্ট হলে পুরো অ্যাপ বন্ধ হয়ে গেলে ইউজাররা অপেক্ষা করবে না। তিনি চান backup path স্বয়ংক্রিয়ভাবে চালু হোক।

`Fail-Over` টপিকটা failure detect করে traffic/workload healthy backup node/service-এ সরিয়ে নেওয়ার design নিয়ে।

Failover design-এ detection speed, false positives, split-brain risk, state synchronization, এবং client impact গুরুত্বপূর্ণ।

শুধু backup রাখা যথেষ্ট না; switch-over কীভাবে হবে সেটা design না করলে failover plan কাগজে থাকে।

সহজ করে বললে `Fail-Over` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: Failover is switching traffic from a failed component to a healthy backup component।

বাস্তব উদাহরণ ভাবতে চাইলে `Amazon`-এর মতো সিস্টেমে `Fail-Over`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Fail-Over` আসলে কীভাবে সাহায্য করে?

`Fail-Over` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- failure scenario ধরে detection, isolation, recovery, আর fallback behavior design করতে সাহায্য করে।
- redundancy থাকলেই reliability solved না—এই operational reality স্পষ্ট করে।
- failover, retry, throttling, circuit breaking, degradation mode—কখন কোনটা ব্যবহার করবেন তা বোঝায়।
- RTO/RPO-like thinking, uptime target, আর cost trade-off discuss করতে সহায়তা করে।

---

### কখন `Fail-Over` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → Single-primary DBs, regional সার্ভিসগুলো, অথবা critical সার্ভিসগুলো সাথে standby capacity.
- Business value কোথায় বেশি? → এটি কমায় downtime যখন a primary সার্ভার, ডাটাবেজ, অথবা রিজিয়ন becomes unavailable.
- failure domain কী: instance, AZ, region, dependency, deployment?
- failure detect করার signal কী, এবং automatic reaction কী হবে?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: যদি backup instances হলো cold এবং recovery time হলো longer than acceptable SLO.
- ইন্টারভিউ রেড ফ্ল্যাগ: Assuming failover হলো instant এবং lossless জন্য stateful সিস্টেমগুলো.
- না defining failover trigger criteria.
- Ignoring failback (moving ট্রাফিক back safely later).
- Confusing redundancy সাথে automatic failover.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Fail-Over` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

---

### মন্টুর কেস (ধাপে ধাপে)

- ধাপ ১: primary health signal monitor করুন।
- ধাপ ২: failure declare করার threshold ঠিক করুন।
- ধাপ ৩: standby/secondary-তে traffic/workload shift করুন।
- ধাপ ৪: stale state / duplicate writes risk handle করুন।
- ধাপ ৫: failback strategy ও testing plan রাখুন।

---

### এই টপিকে মন্টু কী সিদ্ধান্ত নিচ্ছে?

- failure domain কী: instance, AZ, region, dependency, deployment?
- failure detect করার signal কী, এবং automatic reaction কী হবে?
- degrade mode, failover, retry, throttling - কোনটা কখন চালু হবে?

---

## এক লাইনে

- `Fail-Over` failure হলেও service continuity, recovery/failover behavior, এবং resilience trade-off design-এর টপিক।
- এই টপিকে বারবার আসতে পারে: fail, over, use case, trade-off, failure case

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Fail-Over` failure handling, service continuity, failover/recovery behavior, এবং resilience design-এর মূল ধারণা বোঝায়।

- Failover হলো switching ট্রাফিক from a failed component to a healthy backup component.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: Failure normal ঘটনা; outage impact কমাতে আগেই detection, isolation, recovery, এবং fallback strategy দরকার।

- এটি কমায় downtime যখন a primary সার্ভার, ডাটাবেজ, অথবা রিজিয়ন becomes unavailable.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: failure mode, detection signal, automatic reaction, degraded mode, এবং recovery trade-off একসাথে ব্যাখ্যা করলে senior insight বোঝায়।

- Failover depends on health detection, timeout thresholds, এবং routing changes (DNS, লোড balancer, ক্লায়েন্ট logic).
- Fast failover lowers downtime but risks false positives; slow failover হলো safer but increases ইউজার impact.
- Stateful components হলো harder: আপনি must handle রেপ্লিকেশন lag, leader election, এবং in-flight রিকোয়েস্টগুলো.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Fail-Over` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Amazon** পারে fail ট্রাফিক from an unhealthy application fleet অথবা AZ to healthy instances যখন/একইসাথে keeping checkout available.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Fail-Over` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: Single-primary DBs, regional সার্ভিসগুলো, অথবা critical সার্ভিসগুলো সাথে standby capacity.
- কখন ব্যবহার করবেন না: যদি backup instances হলো cold এবং recovery time হলো longer than acceptable SLO.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"How do আপনি রোধ করতে split-brain সময় ডাটাবেজ failover?\"
- রেড ফ্ল্যাগ: Assuming failover হলো instant এবং lossless জন্য stateful সিস্টেমগুলো.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Fail-Over`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- না defining failover trigger criteria.
- Ignoring failback (moving ট্রাফিক back safely later).
- Confusing redundancy সাথে automatic failover.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Assuming failover হলো instant এবং lossless জন্য stateful সিস্টেমগুলো.
- কমন ভুল এড়ান: না defining failover trigger criteria.
- স্কেল/রিলায়েবিলিটি আলোচনায় traffic growth, failure case, আর cost একসাথে বলুন।
- কেন দরকার (শর্ট নোট): এটি কমায় downtime যখন a primary সার্ভার, ডাটাবেজ, অথবা রিজিয়ন becomes unavailable.
