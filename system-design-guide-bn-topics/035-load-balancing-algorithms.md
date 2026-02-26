# Load Balancing Algorithms — বাংলা ব্যাখ্যা

_টপিক নম্বর: 035_

## গল্পে বুঝি

মন্টু মিয়াঁ ৮টা app server বসালেন। কিন্তু traffic ভাগ হবে কীভাবে - round robin, least connections, weighted, hash-based - এটা ঠিক না করলে কিছু server idle, কিছু server overloaded হয়ে যায়।

`Load Balancing Algorithms` টপিকটা এই request distribution policy নিয়ে, যা latency, fairness, stickiness, এবং failure behavior-এ প্রভাব ফেলে।

সব algorithm সব workload-এ ভালো না। long-lived connections থাকলে least-connections useful হতে পারে; sticky workload-এ hash-based routing লাগতে পারে।

তাই algorithm নির্বাচন বলতে শুধু নাম বলা না; request shape, session behavior, server heterogeneity, আর health state-এর সাথে মিলিয়ে বেছে নেওয়া।

সহজ করে বললে `Load Balancing Algorithms` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: These are rules used by a লোড ব্যালেন্সার to choose which backend instance receives each request।

বাস্তব উদাহরণ ভাবতে চাইলে `WhatsApp`-এর মতো সিস্টেমে `Load Balancing Algorithms`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Load Balancing Algorithms` আসলে কীভাবে সাহায্য করে?

`Load Balancing Algorithms` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- টপিকটি কোন problem solve করে এবং কোন requirement-এ value দেয়—সেটা পরিষ্কার করতে সাহায্য করে।
- behavior, trade-off, limitation, আর user impact একসাথে design answer-এ আনতে সহায়তা করে।
- diagram/term-এর বাইরে operational implication explain করতে সাহায্য করে।
- interview answer-কে context-aware ও defensible করতে কাঠামো দেয়।

---

### কখন `Load Balancing Algorithms` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → যখন ট্রাফিক patterns vary অথবা backends হলো না identical.
- Business value কোথায় বেশি? → Different workloads এবং backend behaviors need different distribution strategies.
- এই টপিক কোন সমস্যা solve করে - এক লাইনে সেটা কি পরিষ্কার?
- এর core flow/component/assumption কী?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: করবেন না উপর-optimize algorithm selection আগে confirming backend bottlenecks.
- ইন্টারভিউ রেড ফ্ল্যাগ: Picking an algorithm ছাড়া considering connection duration অথবা রিকোয়েস্ট খরচ skew.
- Assuming round robin হলো সবসময় fair.
- Ignoring warm-up effects জন্য newly added instances.
- না considering sticky sessions এবং ক্যাশ locality.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Load Balancing Algorithms` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

---

### মন্টুর কেস (ধাপে ধাপে)

- ধাপ ১: workload বুঝুন - short request না long-lived connection?
- ধাপ ২: server capacity সমান কি না (weighted দরকার কি না) ঠিক করুন।
- ধাপ ৩: stickiness/session affinity লাগলে hashing বা sticky cookie ভাবুন।
- ধাপ ৪: unhealthy node বাদ দেওয়ার health signal যুক্ত করুন।
- ধাপ ৫: p95 latency ও per-node load দেখে algorithm re-tune করুন।

---

### এই টপিকে মন্টু কী সিদ্ধান্ত নিচ্ছে?

- এই টপিক কোন সমস্যা solve করে - এক লাইনে সেটা কি পরিষ্কার?
- এর core flow/component/assumption কী?
- কোন trade-off বা limitation জানালে উত্তর বাস্তবসম্মত হবে?

---

## এক লাইনে

- `Load Balancing Algorithms` user request কোন layer দিয়ে route, balance, cache, বা failover হবে—সেই traffic control design-এর টপিক।
- এই টপিকে বারবার আসতে পারে: round robin, least connections, weighted routing, session affinity, skew/hotspots

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Load Balancing Algorithms` request flow, routing layer, load distribution, এবং fallback path কোথায় কাজ করবে—সেটার মূল ধারণা বোঝায়।

- এগুলো হলো rules used by a লোড balancer to choose যা backend instance receives each রিকোয়েস্ট.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: ভুল routing/load distribution হলে latency, uneven load, failover behavior, আর user experience দ্রুত খারাপ হয়ে যায়।

- Different workloads এবং backend behaviors need different distribution strategies.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: request flow, health signals, routing rules, timeout/retry/fallback interaction একসাথে design করলেই topicটা সঠিকভাবে explain হয়।

- Common algorithms include round robin, weighted round robin, least connections, least রেসপন্স time, এবং hash-based routing.
- Hash-based strategies সাহায্য ক্যাশ locality অথবা session affinity, but পারে cause uneven লোড সময় node changes unless consistent hashing হলো used.
- Algorithm choice should reflect রিকোয়েস্ট খরচ variance, long-lived connections, এবং backend heterogeneity.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Load Balancing Algorithms` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **WhatsApp**-style long-lived connections benefit from algorithms যা consider active connections, না just simple round robin.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Load Balancing Algorithms` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: যখন ট্রাফিক patterns vary অথবা backends হলো না identical.
- কখন ব্যবহার করবেন না: করবেন না উপর-optimize algorithm selection আগে confirming backend bottlenecks.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"যখন would least-connections হতে better than round robin?\"
- রেড ফ্ল্যাগ: Picking an algorithm ছাড়া considering connection duration অথবা রিকোয়েস্ট খরচ skew.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Load Balancing Algorithms`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Assuming round robin হলো সবসময় fair.
- Ignoring warm-up effects জন্য newly added instances.
- না considering sticky sessions এবং ক্যাশ locality.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Picking an algorithm ছাড়া considering connection duration অথবা রিকোয়েস্ট খরচ skew.
- কমন ভুল এড়ান: Assuming round robin হলো সবসময় fair.
- Routing/communication টপিকে latency, retry behavior, এবং observability উল্লেখ করুন।
- কেন দরকার (শর্ট নোট): Different workloads এবং backend behaviors need different distribution strategies.
