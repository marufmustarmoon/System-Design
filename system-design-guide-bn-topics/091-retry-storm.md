# Retry Storm — বাংলা ব্যাখ্যা

_টপিক নম্বর: 091_

## গল্পে বুঝি

মন্টু মিয়াঁর লক্ষ্য হলো failure হলেও পুরো service বন্ধ না হওয়া। কিন্তু redundancy যোগ করলেই reliability solve হয় না; failure detection আর recovery behavior equally গুরুত্বপূর্ণ।

`Retry Storm` টপিকটা reliability/availability design-এর এমন একটি অংশ যা outage impact কমাতে সাহায্য করে।

এখানে shared dependency, retry cascade, stale state, deployment mistakes - এগুলোও failure source হিসেবে ধরতে হয়।

ভালো answer-এ আপনি failure scenario + detection + recovery + trade-off একসাথে explain করবেন।

সহজ করে বললে `Retry Storm` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: A রিট্রাই storm happens when many clients রিট্রাই failing requests simultaneously, making the overloaded system even worse।

বাস্তব উদাহরণ ভাবতে চাইলে `Amazon`-এর মতো সিস্টেমে `Retry Storm`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Retry Storm` আসলে কীভাবে সাহায্য করে?

`Retry Storm` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- failure scenario ধরে detection, isolation, recovery, আর fallback behavior design করতে সাহায্য করে।
- redundancy থাকলেই reliability solved না—এই operational reality স্পষ্ট করে।
- failover, retry, throttling, circuit breaking, degradation mode—কখন কোনটা ব্যবহার করবেন তা বোঝায়।
- RTO/RPO-like thinking, uptime target, আর cost trade-off discuss করতে সহায়তা করে।

---

### কখন `Retry Storm` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → যখন discussing resilience, ক্লায়েন্ট রিট্রাই policy, এবং dependency protection.
- Business value কোথায় বেশি? → রিট্রাইগুলো হলো useful জন্য transient ফেইলিউরগুলো, but uncoordinated রিট্রাইগুলো amplify লোড সময় incidents.
- failure domain কী: instance, AZ, region, dependency, deployment?
- failure detect করার signal কী, এবং automatic reaction কী হবে?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: করবেন না disable রিট্রাইগুলো entirely জন্য transient ফেইলিউরগুলো; design safe রিট্রাইগুলো instead.
- ইন্টারভিউ রেড ফ্ল্যাগ: "Just রিট্রাই 3 times immediately" জুড়ে all ক্লায়েন্টগুলো.
- কোনো jitter in exponential backoff.
- Multiple রিট্রাই layers (ক্লায়েন্ট, গেটওয়ে, সার্ভিস) multiplying total attempts.
- Retrying non-আইডেমপোটেন্ট writes blindly.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Retry Storm` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

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

- `Retry Storm` failure হলেও service continuity, recovery/failover behavior, এবং resilience trade-off design-এর টপিক।
- এই টপিকে বারবার আসতে পারে: failure handling, backoff/jitter, fallback, isolation, cascading failure

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Retry Storm` failure handling, service continuity, failover/recovery behavior, এবং resilience design-এর মূল ধারণা বোঝায়।

- একটি রিট্রাই স্টর্ম happens যখন many ক্লায়েন্টগুলো রিট্রাই failing রিকোয়েস্টগুলো simultaneously, making the overloaded সিস্টেম even worse.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: Failure normal ঘটনা; outage impact কমাতে আগেই detection, isolation, recovery, এবং fallback strategy দরকার।

- রিট্রাইগুলো হলো useful জন্য transient ফেইলিউরগুলো, but uncoordinated রিট্রাইগুলো amplify লোড সময় incidents.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: failure mode, detection signal, automatic reaction, degraded mode, এবং recovery trade-off একসাথে ব্যাখ্যা করলে senior insight বোঝায়।

- যখন ল্যাটেন্সি rises অথবা errors spike, ক্লায়েন্টগুলো time out এবং রিট্রাই, multiplying রিকোয়েস্ট volume.
- Mitigations include exponential backoff, jitter, সার্কিট ব্রেকারs, রেট লিমিটিং, এবং আইডেমপোটেন্ট operations.
- Compare সাথে normal রিট্রাইগুলো: রিট্রাইগুলো সাহায্য recovery শুধু যখন they কমাতে pressure, না যখন they synchronize spikes.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Retry Storm` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Amazon** সার্ভিস incidents পারে worsen যদি multiple upstream সার্ভিসগুলো all রিট্রাই the same dependency aggressively ছাড়া jitter.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Retry Storm` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: যখন discussing resilience, ক্লায়েন্ট রিট্রাই policy, এবং dependency protection.
- কখন ব্যবহার করবেন না: করবেন না disable রিট্রাইগুলো entirely জন্য transient ফেইলিউরগুলো; design safe রিট্রাইগুলো instead.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"How would আপনি রোধ করতে রিট্রাইগুলো from taking down a recovering সার্ভিস?\"
- রেড ফ্ল্যাগ: "Just রিট্রাই 3 times immediately" জুড়ে all ক্লায়েন্টগুলো.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Retry Storm`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- কোনো jitter in exponential backoff.
- Multiple রিট্রাই layers (ক্লায়েন্ট, গেটওয়ে, সার্ভিস) multiplying total attempts.
- Retrying non-আইডেমপোটেন্ট writes blindly.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: "Just রিট্রাই 3 times immediately" জুড়ে all ক্লায়েন্টগুলো.
- কমন ভুল এড়ান: কোনো jitter in exponential backoff.
- ইন্টারভিউতে কখন ব্যবহার করবেন/করবেন না - দুইটাই বললে উত্তরের মান বাড়ে।
- কেন দরকার (শর্ট নোট): রিট্রাইগুলো হলো useful জন্য transient ফেইলিউরগুলো, but uncoordinated রিট্রাইগুলো amplify লোড সময় incidents.
