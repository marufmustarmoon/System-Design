# Availability vs Consistency — বাংলা ব্যাখ্যা

_টপিক নম্বর: 006_

## গল্পে বুঝি

মন্টু মিয়াঁর দুই ডাটাসেন্টারের মধ্যে network problem হলো। এখন প্রশ্ন: system কি requests serve করতে থাকবে (availability), নাকি conflicting data এড়াতে কিছু requests block করবে (consistency)?

`Availability vs Consistency` টপিকটা ঠিক এই partition/failure পরিস্থিতিতে design decision বোঝায়। স্বাভাবিক অবস্থায় অনেক system-ই fast এবং consistent দেখাতে পারে; আসল পরীক্ষা network partition-এ।

এখানে ভুল বোঝাবুঝি হয় যখন সবাই ভাবে AP/CP মানে database product label। আসলে এটা workload + failure mode + product guarantee মিলিয়ে নেওয়া architectural choice।

মন্টুর জন্য এই টপিকের বাস্তব মানে: “সিস্টেম fail করলে user কী experience পাবে?” - এই প্রশ্নের আগাম উত্তর।

সহজ করে বললে `Availability vs Consistency` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: Availability means the system responds to requests (even if data may be stale)।

বাস্তব উদাহরণ ভাবতে চাইলে `Amazon`-এর মতো সিস্টেমে `Availability vs Consistency`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Availability vs Consistency` আসলে কীভাবে সাহায্য করে?

`Availability vs Consistency` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- feature/endpoint অনুযায়ী consistency guarantee আলাদা করে define করতে সাহায্য করে।
- staleness, read/write path, replication lag, আর user-visible anomalies স্পষ্ট করতে সাহায্য করে।
- availability/latency বনাম correctness trade-off product behavior-এর সাথে map করতে সহায়তা করে।
- “strong vs eventual” discussion-কে buzzword-এর বদলে concrete API behavior-এ নামিয়ে আনে।

---

### কখন `Availability vs Consistency` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → যখন designing replicated ডেটা stores, failover behavior, অথবা multi-রিজিয়ন reads.
- Business value কোথায় বেশি? → ডিস্ট্রিবিউটেড সিস্টেম face network ফেইলিউরগুলো এবং replica lag.
- কোন API/feature-এ strong consistency লাগবে, আর কোথায় eventual চলবে?
- write acknowledgment কোন শর্তে success ধরা হবে (leader/quorum/replica lag)?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: করবেন না force স্ট্রং কনসিসটেন্সি everywhere যদি it kills ল্যাটেন্সি এবং অ্যাভেইলেবিলিটি ছাড়া business need.
- ইন্টারভিউ রেড ফ্ল্যাগ: Saying "কনসিসটেন্সি" ছাড়া specifying what ডেটা এবং what guarantee.
- Believing কনসিসটেন্সি সবসময় মানে ACID transactions জুড়ে the entire সিস্টেম.
- Assuming অ্যাভেইলেবিলিটি মানে correctness.
- Treating the ট্রেড-অফ as static জুড়ে all endpoints.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Availability vs Consistency` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

---

### মন্টুর কেস (ধাপে ধাপে)

- ধাপ ১: partition scenario ধরুন (region link down / replica unreachable)।
- ধাপ ২: system write/read serve করবে নাকি reject করবে - policy ঠিক করুন।
- ধাপ ৩: conflicting updates হলে merge/reconcile strategy ভাবুন (AP case-এ)।
- ধাপ ৪: strict correctness চাইলে request blocking/leader-only path ভাবুন (CP-like case)।
- ধাপ ৫: endpoint-by-endpoint behavior document করুন, generic label-এ সীমাবদ্ধ থাকবেন না।

---

### এই টপিকে মন্টু কী সিদ্ধান্ত নিচ্ছে?

- কোন API/feature-এ strong consistency লাগবে, আর কোথায় eventual চলবে?
- write acknowledgment কোন শর্তে success ধরা হবে (leader/quorum/replica lag)?
- user-facing behavior কী হবে: stale data accept করবেন, নাকি latency বাড়িয়ে fresh data দেবেন?

---

## এক লাইনে

- `Availability vs Consistency` distributed data update কখন/কীভাবে visible হবে এবং correctness বনাম latency/availability trade-off কী হবে—সেটা নির্ধারণের টপিক।
- এই টপিকে বারবার আসতে পারে: consistency guarantee, staleness window, read/write behavior, user-visible anomalies, trade-off

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Availability vs Consistency` ডেটা update-এর visibility guarantee, user-visible correctness expectation, আর consistency-level trade-off বোঝায়।

- **অ্যাভেইলেবিলিটি** মানে the সিস্টেম responds to রিকোয়েস্টগুলো (even যদি ডেটা may হতে stale).
- **কনসিসটেন্সি** মানে all ক্লায়েন্টগুলো see the same, most recent ডেটা view (within the chosen কনসিসটেন্সি model).

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: replication/read-write path আলাদা হলে কোন data কখন visible হবে সেটা define না করলে user-visible inconsistency তৈরি হয়।

- ডিস্ট্রিবিউটেড সিস্টেম face network ফেইলিউরগুলো এবং replica lag.
- আপনি অনেক সময় need to choose what to sacrifice temporarily সময় পার্টিশনগুলো অথবা outages.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: endpoint/feature অনুযায়ী guarantee আলাদা করে, acceptable staleness ও partition behavior define করে design করা senior-level insight।

- এটি হলো a ট্রেড-অফ, না a binary label জন্য the whole company.
- Different operations পারে choose differently: reading profile pictures পারে tolerate staleness; balance transfers usually পারে না.
- Compare এটি সাথে CAP discussions: interviews অনেক সময় expect operation-level choices, না one global answer.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Availability vs Consistency` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Amazon** product reviews এবং counts may show slightly stale ডেটা, but payment অথরাইজেশন paths require tighter কনসিসটেন্সি guarantees.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Availability vs Consistency` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: যখন designing replicated ডেটা stores, failover behavior, অথবা multi-রিজিয়ন reads.
- কখন ব্যবহার করবেন না: করবেন না force স্ট্রং কনসিসটেন্সি everywhere যদি it kills ল্যাটেন্সি এবং অ্যাভেইলেবিলিটি ছাড়া business need.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"যা endpoints in আপনার সিস্টেম পারে হতে eventually consistent?\"
- রেড ফ্ল্যাগ: Saying "কনসিসটেন্সি" ছাড়া specifying what ডেটা এবং what guarantee.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Availability vs Consistency`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Believing কনসিসটেন্সি সবসময় মানে ACID transactions জুড়ে the entire সিস্টেম.
- Assuming অ্যাভেইলেবিলিটি মানে correctness.
- Treating the ট্রেড-অফ as static জুড়ে all endpoints.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Saying "কনসিসটেন্সি" ছাড়া specifying what ডেটা এবং what guarantee.
- কমন ভুল এড়ান: Believing কনসিসটেন্সি সবসময় মানে ACID transactions জুড়ে the entire সিস্টেম.
- Consistency টপিকে endpoint-by-endpoint guarantee (read-after-write, eventual, strong) বললে উত্তর অনেক পরিষ্কার হয়।
- কেন দরকার (শর্ট নোট): ডিস্ট্রিবিউটেড সিস্টেম face network ফেইলিউরগুলো এবং replica lag.
