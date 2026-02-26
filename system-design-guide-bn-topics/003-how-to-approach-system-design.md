# How to approach System Design? — বাংলা ব্যাখ্যা

_টপিক নম্বর: 003_

## গল্পে বুঝি

মন্টু মিয়াঁ `How to approach System Design?` টপিক থেকে শিখছেন system design-এ আসল বিষয় শুধু diagram না; reasoning structure।

একটা problem statement শুনে requirements, constraints, scale, failure, APIs, data model, এবং trade-off কীভাবে ধরতে হয় - এই foundation না থাকলে পরের advanced topic-ও অস্পষ্ট লাগে।

Interview-তে strong candidate সাধারণত প্রথমেই scope clear করে, assumptions বলে, তারপর design layer-by-layer খুলে।

এই foundation টপিকগুলো সেই disciplined approach তৈরি করে।

সহজ করে বললে `How to approach System Design?` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: A repeatable interview process for turning a vague prompt into a concrete, defensible design।

বাস্তব উদাহরণ ভাবতে চাইলে `Uber`-এর মতো সিস্টেমে `How to approach System Design?`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `How to approach System Design?` আসলে কীভাবে সাহায্য করে?

`How to approach System Design?` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- problem statement থেকে requirements, constraints, আর success criteria structuredভাবে বের করতে সাহায্য করে।
- diagram-এর আগে reasoning framework দাঁড় করাতে সাহায্য করে।
- trade-off, failure case, এবং scalability question আগে থেকে ধরতে সুবিধা দেয়।
- interview answer-কে random tool listing থেকে structured design discussion-এ বদলে দেয়।

---

### কখন `How to approach System Design?` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → In every সিস্টেম Design interview, especially ambiguous prompts.
- Business value কোথায় বেশি? → Interview prompts হলো intentionally open-ended.
- এই টপিক কোন সমস্যা solve করে - এক লাইনে সেটা কি পরিষ্কার?
- এর core flow/component/assumption কী?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: আপনি should না rigidly follow a checklist যদি the interviewer asks to deep-dive a specific area.
- ইন্টারভিউ রেড ফ্ল্যাগ: Spending 15 minutes estimating QPS আগে understanding product behavior.
- Treating estimates as exact এর বদলে directional.
- না separating functional requirements from non-functional requirements.
- Forgetting to summarize ট্রেড-অফ at the end.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `How to approach System Design?` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

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

- `How to approach System Design?` সিস্টেম ডিজাইনের foundational thinking framework—requirements, constraints, trade-off, আর structured reasoning দিয়ে design শুরু করার পথ।
- এই টপিকে বারবার আসতে পারে: how, requirements clarity, non-functional constraints, trade-offs, failure cases

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `How to approach System Design?` টপিকটি সিস্টেম ডিজাইনের বেসিক চিন্তার কাঠামো, terminology, এবং problem-framing বোঝার ভিত্তি তৈরি করে।

- একটি repeatable interview process জন্য turning a vague prompt into a concrete, defensible design.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: সিস্টেম ডিজাইনে feature-only ভাবলে scale, failure, cost, এবং maintainability মিস হয়ে যায়; তাই structured design thinking দরকার।

- Interview prompts হলো intentionally open-ended.
- একটি consistent approach রোধ করে missing critical requirements অথবা spending all time on one component.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: এই অংশে requirement → architecture → bottleneck → trade-off → failure behavior ধারাবাহিকভাবে explain করলে senior-level reasoning দেখায়।

- Start সাথে scope এবং success মেট্রিকস, then estimate ট্রাফিক/ডেটা, define APIs, sketch high-level components, এবং drill into bottlenecks.
- স্টেট assumptions explicitly; interviewers reward transparent reasoning.
- Leave time জন্য ট্রেড-অফ, ফেইলিউর scenarios, এবং future improvements.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `How to approach System Design?` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Uber** ride matching design starts differently যদি the focus হলো rider ETA, pricing, dispatch থ্রুপুট, অথবা driver tracking.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `How to approach System Design?` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: In every সিস্টেম Design interview, especially ambiguous prompts.
- কখন ব্যবহার করবেন না: আপনি should না rigidly follow a checklist যদি the interviewer asks to deep-dive a specific area.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"What requirements would আপনি clarify first?\"
- রেড ফ্ল্যাগ: Spending 15 minutes estimating QPS আগে understanding product behavior.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `How to approach System Design?`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Treating estimates as exact এর বদলে directional.
- না separating functional requirements from non-functional requirements.
- Forgetting to summarize ট্রেড-অফ at the end.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Spending 15 minutes estimating QPS আগে understanding product behavior.
- কমন ভুল এড়ান: Treating estimates as exact এর বদলে directional.
- ইন্টারভিউতে কখন ব্যবহার করবেন/করবেন না - দুইটাই বললে উত্তরের মান বাড়ে।
- কেন দরকার (শর্ট নোট): Interview prompts হলো intentionally open-ended.
