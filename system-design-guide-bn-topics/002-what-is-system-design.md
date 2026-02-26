# What is System Design? — বাংলা ব্যাখ্যা

_টপিক নম্বর: 002_

## গল্পে বুঝি

মন্টু মিয়াঁ `What is System Design?` টপিক থেকে শিখছেন system design-এ আসল বিষয় শুধু diagram না; reasoning structure।

একটা problem statement শুনে requirements, constraints, scale, failure, APIs, data model, এবং trade-off কীভাবে ধরতে হয় - এই foundation না থাকলে পরের advanced topic-ও অস্পষ্ট লাগে।

Interview-তে strong candidate সাধারণত প্রথমেই scope clear করে, assumptions বলে, তারপর design layer-by-layer খুলে।

এই foundation টপিকগুলো সেই disciplined approach তৈরি করে।

সহজ করে বললে `What is System Design?` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: It is the blueprint of how services, ডাটাবেজs, ক্যাশs, কিউs, and clients interact to solve a business problem।

বাস্তব উদাহরণ ভাবতে চাইলে `Amazon`-এর মতো সিস্টেমে `What is System Design?`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `What is System Design?` আসলে কীভাবে সাহায্য করে?

`What is System Design?` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- problem statement থেকে requirements, constraints, আর success criteria structuredভাবে বের করতে সাহায্য করে।
- diagram-এর আগে reasoning framework দাঁড় করাতে সাহায্য করে।
- trade-off, failure case, এবং scalability question আগে থেকে ধরতে সুবিধা দেয়।
- interview answer-কে random tool listing থেকে structured design discussion-এ বদলে দেয়।

---

### কখন `What is System Design?` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → যখন multiple components, টিমগুলো, অথবা reliability constraints হলো involved.
- Business value কোথায় বেশি? → Code quality alone does না রোধ করতে outages caused by bottlenecks, contention, অথবা bad dependencies.
- এই টপিক কোন সমস্যা solve করে - এক লাইনে সেটা কি পরিষ্কার?
- এর core flow/component/assumption কী?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: যখন a coding interview asks জন্য an algorithm এবং আপনি উপর-architect the answer.
- ইন্টারভিউ রেড ফ্ল্যাগ: Defining সিস্টেম Design as শুধু "drawing boxes এবং arrows."
- Assuming সিস্টেম Design হলো শুধু জন্য massive companies.
- Ignoring operational concerns like ডিপ্লয়মেন্ট, মনিটরিং, এবং rollback.
- Confusing architecture patterns সাথে actual requirement-driven design.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `What is System Design?` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

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

- `What is System Design?` সিস্টেম ডিজাইনের foundational thinking framework—requirements, constraints, trade-off, আর structured reasoning দিয়ে design শুরু করার পথ।
- এই টপিকে বারবার আসতে পারে: requirements clarity, non-functional constraints, trade-offs, failure cases, structured answer

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `What is System Design?` টপিকটি সিস্টেম ডিজাইনের বেসিক চিন্তার কাঠামো, terminology, এবং problem-framing বোঝার ভিত্তি তৈরি করে।

- এটি হলো the blueprint of how সার্ভিসগুলো, ডাটাবেজগুলো, ক্যাশগুলো, কিউগুলো, এবং ক্লায়েন্টগুলো interact to solve a business problem.
- এটি includes both logical design (what talks to what) এবং operational design (how it runs in production).

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: সিস্টেম ডিজাইনে feature-only ভাবলে scale, failure, cost, এবং maintainability মিস হয়ে যায়; তাই structured design thinking দরকার।

- Code quality alone does না রোধ করতে outages caused by bottlenecks, contention, অথবা bad dependencies.
- সিস্টেম Design aligns engineering decisions সাথে product requirements এবং expected growth.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: এই অংশে requirement → architecture → bottleneck → trade-off → failure behavior ধারাবাহিকভাবে explain করলে senior-level reasoning দেখায়।

- একটি useful definition includes interfaces, স্টেট ওনারশিপ, স্কেলিং strategy, এবং ফেইলিউর হ্যান্ডলিং.
- Senior engineers focus on boundaries: যা সার্ভিস owns ডেটা, যা path হলো synchronous, এবং what পারে fail independently.
- Compared সাথে low-level design, সিস্টেম Design emphasizes ডিস্ট্রিবিউটেড আচরণ, না class hierarchies.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `What is System Design?` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Amazon** checkout involves cart, inventory, payment, fraud checks, এবং order সার্ভিসগুলো সাথে different ল্যাটেন্সি এবং কনসিসটেন্সি needs.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `What is System Design?` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: যখন multiple components, টিমগুলো, অথবা reliability constraints হলো involved.
- কখন ব্যবহার করবেন না: যখন a coding interview asks জন্য an algorithm এবং আপনি উপর-architect the answer.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"What হলো the core components আপনি would include in এটি design?\"
- রেড ফ্ল্যাগ: Defining সিস্টেম Design as শুধু "drawing boxes এবং arrows."

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `What is System Design?`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Assuming সিস্টেম Design হলো শুধু জন্য massive companies.
- Ignoring operational concerns like ডিপ্লয়মেন্ট, মনিটরিং, এবং rollback.
- Confusing architecture patterns সাথে actual requirement-driven design.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Defining সিস্টেম Design as শুধু "drawing boxes এবং arrows."
- কমন ভুল এড়ান: Assuming সিস্টেম Design হলো শুধু জন্য massive companies.
- ইন্টারভিউতে কখন ব্যবহার করবেন/করবেন না - দুইটাই বললে উত্তরের মান বাড়ে।
- কেন দরকার (শর্ট নোট): Code quality alone does না রোধ করতে outages caused by bottlenecks, contention, অথবা bad dependencies.
