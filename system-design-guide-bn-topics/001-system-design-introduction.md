# System Design – Introduction — বাংলা ব্যাখ্যা

_টপিক নম্বর: 001_

## গল্পে বুঝি

মন্টু মিয়াঁ `System Design – Introduction` টপিক থেকে শিখছেন system design-এ আসল বিষয় শুধু diagram না; reasoning structure।

একটা problem statement শুনে requirements, constraints, scale, failure, APIs, data model, এবং trade-off কীভাবে ধরতে হয় - এই foundation না থাকলে পরের advanced topic-ও অস্পষ্ট লাগে।

Interview-তে strong candidate সাধারণত প্রথমেই scope clear করে, assumptions বলে, তারপর design layer-by-layer খুলে।

এই foundation টপিকগুলো সেই disciplined approach তৈরি করে।

সহজ করে বললে `System Design – Introduction` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: System Design is the practice of choosing components, data flow, and trade-offs to build software that works reliably at real-world scale।

বাস্তব উদাহরণ ভাবতে চাইলে `YouTube`-এর মতো সিস্টেমে `System Design – Introduction`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `System Design – Introduction` আসলে কীভাবে সাহায্য করে?

`System Design – Introduction` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- problem statement থেকে requirements, constraints, আর success criteria structuredভাবে বের করতে সাহায্য করে।
- diagram-এর আগে reasoning framework দাঁড় করাতে সাহায্য করে।
- trade-off, failure case, এবং scalability question আগে থেকে ধরতে সুবিধা দেয়।
- interview answer-কে random tool listing থেকে structured design discussion-এ বদলে দেয়।

---

### কখন `System Design – Introduction` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → জন্য designing new সিস্টেমগুলো অথবা evolving existing সিস্টেমগুলো এর অধীনে scale/reliability constraints.
- Business value কোথায় বেশি? → একটি feature যা কাজ করে on one machine পারে fail যখন ইউজাররা, ডেটা, অথবা ট্রাফিক grow.
- এই টপিক কোন সমস্যা solve করে - এক লাইনে সেটা কি পরিষ্কার?
- এর core flow/component/assumption কী?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: জন্য small scripts অথবা local tools যেখানে operational overhead matters more than architecture.
- ইন্টারভিউ রেড ফ্ল্যাগ: Jumping straight to Kafka, Redis, অথবা শার্ডিং ছাড়া clarifying requirements.
- Thinking there হলো one "correct" design.
- Ignoring non-functional requirements (scale, ল্যাটেন্সি, ডিউরেবিলিটি, খরচ).
- Treating diagrams as design এর বদলে explaining behavior এর অধীনে লোড/ফেইলিউর.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `System Design – Introduction` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

---

### মন্টুর কেস (ধাপে ধাপে)

- ধাপ ১: functional requirements clarify করুন।
- ধাপ ২: non-functional priorities ঠিক করুন।
- ধাপ ৩: high-level design sketch করুন।
- ধাপ ৪: bottlenecks/failure/trade-offs deep dive করুন।
- ধাপ ৫: summary ও future improvements দিয়ে wrap up করুন।

---

### এই টপিকে মন্টু কী সিদ্ধান্ত নিচ্ছে?

- এই টপিক কোন সমস্যা solve করে - এক লাইনে সেটা কি পরিষ্কার?
- এর core flow/component/assumption কী?
- কোন trade-off বা limitation জানালে উত্তর বাস্তবসম্মত হবে?

---

## এক লাইনে

- `System Design – Introduction` সিস্টেম ডিজাইনের foundational thinking framework—requirements, constraints, trade-off, আর structured reasoning দিয়ে design শুরু করার পথ।
- এই টপিকে বারবার আসতে পারে: introduction, requirements clarity, non-functional constraints, trade-offs, failure cases

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `System Design – Introduction` টপিকটি সিস্টেম ডিজাইনের বেসিক চিন্তার কাঠামো, terminology, এবং problem-framing বোঝার ভিত্তি তৈরি করে।

- সিস্টেম Design হলো the practice of choosing components, ডেটা flow, এবং ট্রেড-অফ to বানানো software যা কাজ করে reliably at বাস্তব স্কেল.
- ইন্টারভিউতে, it হলো less about perfect architecture এবং more about structured thinking.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: সিস্টেম ডিজাইনে feature-only ভাবলে scale, failure, cost, এবং maintainability মিস হয়ে যায়; তাই structured design thinking দরকার।

- একটি feature যা কাজ করে on one machine পারে fail যখন ইউজাররা, ডেটা, অথবা ট্রাফিক grow.
- টিমগুলো need a way to reason about scale, ফেইলিউরগুলো, খরচ, এবং মেইনটেইনেবিলিটি আগে building.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: এই অংশে requirement → architecture → bottleneck → trade-off → failure behavior ধারাবাহিকভাবে explain করলে senior-level reasoning দেখায়।

- আপনি break a problem into requirements, constraints, APIs, ডেটা model, ট্রাফিক patterns, এবং ফেইলিউর মোড.
- Good design হলো ট্রেড-অফ management: ল্যাটেন্সি vs খরচ, কনসিসটেন্সি vs অ্যাভেইলেবিলিটি, speed of delivery vs long-term complexity.
- Interviewers usually score clarity of reasoning more than naming fancy tools.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `System Design – Introduction` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **YouTube** needs very different design choices জন্য video upload, encoding, search, recommendations, এবং playback, even though all হলো part of one product.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `System Design – Introduction` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: জন্য designing new সিস্টেমগুলো অথবা evolving existing সিস্টেমগুলো এর অধীনে scale/reliability constraints.
- কখন ব্যবহার করবেন না: জন্য small scripts অথবা local tools যেখানে operational overhead matters more than architecture.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"Design a URL shortener / chat সিস্টেম / video platform. How do আপনি start?\"
- রেড ফ্ল্যাগ: Jumping straight to Kafka, Redis, অথবা শার্ডিং ছাড়া clarifying requirements.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `System Design – Introduction`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Thinking there হলো one "correct" design.
- Ignoring non-functional requirements (scale, ল্যাটেন্সি, ডিউরেবিলিটি, খরচ).
- Treating diagrams as design এর বদলে explaining behavior এর অধীনে লোড/ফেইলিউর.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Jumping straight to Kafka, Redis, অথবা শার্ডিং ছাড়া clarifying requirements.
- কমন ভুল এড়ান: Thinking there হলো one "correct" design.
- ইন্টারভিউতে কখন ব্যবহার করবেন/করবেন না - দুইটাই বললে উত্তরের মান বাড়ে।
- কেন দরকার (শর্ট নোট): একটি feature যা কাজ করে on one machine পারে fail যখন ইউজাররা, ডেটা, অথবা ট্রাফিক grow.
