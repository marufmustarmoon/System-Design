# Deployment Stamps — বাংলা ব্যাখ্যা

_টপিক নম্বর: 142_

## গল্পে বুঝি

মন্টু মিয়াঁর লক্ষ্য হলো failure হলেও পুরো service বন্ধ না হওয়া। কিন্তু redundancy যোগ করলেই reliability solve হয় না; failure detection আর recovery behavior equally গুরুত্বপূর্ণ।

`Deployment Stamps` টপিকটা reliability/availability design-এর এমন একটি অংশ যা outage impact কমাতে সাহায্য করে।

এখানে shared dependency, retry cascade, stale state, deployment mistakes - এগুলোও failure source হিসেবে ধরতে হয়।

ভালো answer-এ আপনি failure scenario + detection + recovery + trade-off একসাথে explain করবেন।

সহজ করে বললে `Deployment Stamps` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: In the HA context, deployment stamps are duplicated production units that limit blast radius and support fast traffic shift during failures।

বাস্তব উদাহরণ ভাবতে চাইলে `Google`-এর মতো সিস্টেমে `Deployment Stamps`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Deployment Stamps` আসলে কীভাবে সাহায্য করে?

`Deployment Stamps` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- failure scenario ধরে detection, isolation, recovery, আর fallback behavior design করতে সাহায্য করে।
- redundancy থাকলেই reliability solved না—এই operational reality স্পষ্ট করে।
- failover, retry, throttling, circuit breaking, degradation mode—কখন কোনটা ব্যবহার করবেন তা বোঝায়।
- RTO/RPO-like thinking, uptime target, আর cost trade-off discuss করতে সহায়তা করে।

---

### কখন `Deployment Stamps` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → High-scale, high-SLO সিস্টেমগুলো needing blast-radius containment.
- Business value কোথায় বেশি? → HA সিস্টেমগুলো need isolation so one ডিপ্লয়মেন্ট অথবা infrastructure issue does না cause a global আউটেজ.
- failure domain কী: instance, AZ, region, dependency, deployment?
- failure detect করার signal কী, এবং automatic reaction কী হবে?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: Single-টিম সিস্টেমগুলো ছাড়া capacity to operate many stamps.
- ইন্টারভিউ রেড ফ্ল্যাগ: কোনো failover capacity planning জুড়ে stamps.
- Replicating stamps but centralizing all স্টেট in one dependency.
- কোনো stamp-level মেট্রিকস/অ্যালার্ট.
- Inconsistent configs জুড়ে stamps.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Deployment Stamps` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

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

- `Deployment Stamps` failure হলেও service continuity, recovery/failover behavior, এবং resilience trade-off design-এর টপিক।
- এই টপিকে বারবার আসতে পারে: deployment, stamps, use case, trade-off, failure case

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Deployment Stamps` failure handling, service continuity, failover/recovery behavior, এবং resilience design-এর মূল ধারণা বোঝায়।

- In the HA context, ডিপ্লয়মেন্ট stamps হলো duplicated production units যা limit blast radius এবং সাপোর্ট fast ট্রাফিক shift সময় ফেইলিউরগুলো.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: Failure normal ঘটনা; outage impact কমাতে আগেই detection, isolation, recovery, এবং fallback strategy দরকার।

- HA সিস্টেমগুলো need isolation so one ডিপ্লয়মেন্ট অথবা infrastructure issue does না cause a global আউটেজ.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: failure mode, detection signal, automatic reaction, degraded mode, এবং recovery trade-off একসাথে ব্যাখ্যা করলে senior insight বোঝায়।

- Stamps provide independent capacity slices সাথে standardized automation.
- HA value comes from being able to route around a failed stamp quickly এবং safely.
- Compared সাথে the earlier অ্যাভেইলেবিলিটি discussion, the HA focus হলো on stricter automation, capacity headroom, এবং failover readiness.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Deployment Stamps` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Google**-style regional সার্ভিস stacks পারে হতে operated as stamps to contain ফেইলিউরগুলো এবং সাপোর্ট controlled rollouts.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Deployment Stamps` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: High-scale, high-SLO সিস্টেমগুলো needing blast-radius containment.
- কখন ব্যবহার করবেন না: Single-টিম সিস্টেমগুলো ছাড়া capacity to operate many stamps.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"How much spare capacity do আপনি keep in other stamps জন্য failover?\"
- রেড ফ্ল্যাগ: কোনো failover capacity planning জুড়ে stamps.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Deployment Stamps`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Replicating stamps but centralizing all স্টেট in one dependency.
- কোনো stamp-level মেট্রিকস/অ্যালার্ট.
- Inconsistent configs জুড়ে stamps.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: কোনো failover capacity planning জুড়ে stamps.
- কমন ভুল এড়ান: Replicating stamps but centralizing all স্টেট in one dependency.
- ইন্টারভিউতে কখন ব্যবহার করবেন/করবেন না - দুইটাই বললে উত্তরের মান বাড়ে।
- কেন দরকার (শর্ট নোট): HA সিস্টেমগুলো need isolation so one ডিপ্লয়মেন্ট অথবা infrastructure issue does না cause a global আউটেজ.
