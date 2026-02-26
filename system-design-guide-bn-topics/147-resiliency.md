# Resiliency — বাংলা ব্যাখ্যা

_টপিক নম্বর: 147_

## গল্পে বুঝি

মন্টু মিয়াঁর লক্ষ্য হলো failure হলেও পুরো service বন্ধ না হওয়া। কিন্তু redundancy যোগ করলেই reliability solve হয় না; failure detection আর recovery behavior equally গুরুত্বপূর্ণ।

`Resiliency` টপিকটা reliability/availability design-এর এমন একটি অংশ যা outage impact কমাতে সাহায্য করে।

এখানে shared dependency, retry cascade, stale state, deployment mistakes - এগুলোও failure source হিসেবে ধরতে হয়।

ভালো answer-এ আপনি failure scenario + detection + recovery + trade-off একসাথে explain করবেন।

সহজ করে বললে `Resiliency` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: Resiliency is the ability of a system to absorb faults, recover, and continue delivering acceptable behavior।

বাস্তব উদাহরণ ভাবতে চাইলে `Uber`-এর মতো সিস্টেমে `Resiliency`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Resiliency` আসলে কীভাবে সাহায্য করে?

`Resiliency` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- failure scenario ধরে detection, isolation, recovery, আর fallback behavior design করতে সাহায্য করে।
- redundancy থাকলেই reliability solved না—এই operational reality স্পষ্ট করে।
- failover, retry, throttling, circuit breaking, degradation mode—কখন কোনটা ব্যবহার করবেন তা বোঝায়।
- RTO/RPO-like thinking, uptime target, আর cost trade-off discuss করতে সহায়তা করে।

---

### কখন `Resiliency` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → Any production সিস্টেম সাথে dependencies, async workflows, এবং external integrations.
- Business value কোথায় বেশি? → In ডিস্ট্রিবিউটেড সিস্টেম, ফেইলিউরগুলো হলো unavoidable; resilient সিস্টেমগুলো fail partially, recover quickly, এবং এড়াতে cascading outages.
- failure domain কী: instance, AZ, region, dependency, deployment?
- failure detect করার signal কী, এবং automatic reaction কী হবে?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: করবেন না overbuild resiliency controls জন্য trivial offline tools.
- ইন্টারভিউ রেড ফ্ল্যাগ: শুধু discussing redundancy, না recovery behavior.
- Treating রিট্রাইগুলো as the entire resiliency strategy.
- Ignoring compensation এবং idempotency.
- কোনো drills/testing জন্য ফেইলিউর scenarios.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Resiliency` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

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

- `Resiliency` failure হলেও service continuity, recovery/failover behavior, এবং resilience trade-off design-এর টপিক।
- এই টপিকে বারবার আসতে পারে: failure handling, backoff/jitter, fallback, isolation, cascading failure

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Resiliency` failure handling, service continuity, failover/recovery behavior, এবং resilience design-এর মূল ধারণা বোঝায়।

- Resiliency হলো the ability of a সিস্টেম to absorb faults, recover, এবং continue delivering acceptable behavior.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: Failure normal ঘটনা; outage impact কমাতে আগেই detection, isolation, recovery, এবং fallback strategy দরকার।

- In ডিস্ট্রিবিউটেড সিস্টেম, ফেইলিউরগুলো হলো unavoidable; resilient সিস্টেমগুলো fail partially, recover quickly, এবং এড়াতে cascading outages.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: failure mode, detection signal, automatic reaction, degraded mode, এবং recovery trade-off একসাথে ব্যাখ্যা করলে senior insight বোঝায়।

- Resiliency combines isolation, রিট্রাইগুলো, timeouts, health signals, fallback behavior, এবং recovery workflows.
- এটি differs from অ্যাভেইলেবিলিটি by focusing on how the সিস্টেম behaves সময় এবং পরে faults, না just uptime percentage.
- Strong interview answers describe both automatic recovery এবং ইউজার-visible degradation behavior.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Resiliency` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Uber** সিস্টেমগুলো degrade non-critical features এবং recover background pipelines ছাড়া disrupting core trip flows সময় incidents.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Resiliency` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: Any production সিস্টেম সাথে dependencies, async workflows, এবং external integrations.
- কখন ব্যবহার করবেন না: করবেন না overbuild resiliency controls জন্য trivial offline tools.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"How does আপনার সিস্টেম recover from partial ফেইলিউরগুলো ছাড়া duplicate side effects?\"
- রেড ফ্ল্যাগ: শুধু discussing redundancy, না recovery behavior.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Resiliency`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Treating রিট্রাইগুলো as the entire resiliency strategy.
- Ignoring compensation এবং idempotency.
- কোনো drills/testing জন্য ফেইলিউর scenarios.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: শুধু discussing redundancy, না recovery behavior.
- কমন ভুল এড়ান: Treating রিট্রাইগুলো as the entire resiliency strategy.
- স্কেল/রিলায়েবিলিটি আলোচনায় traffic growth, failure case, আর cost একসাথে বলুন।
- কেন দরকার (শর্ট নোট): In ডিস্ট্রিবিউটেড সিস্টেম, ফেইলিউরগুলো হলো unavoidable; resilient সিস্টেমগুলো fail partially, recover quickly, এবং এড়াতে cascading outages.
