# Strong Consistency — বাংলা ব্যাখ্যা

_টপিক নম্বর: 013_

## গল্পে বুঝি

মন্টু মিয়াঁ subscription cancel করার পর চাইছেন সব জায়গায় সাথে সাথে “cancelled” status দেখা যাক, যাতে ভুল billing না হয়। এখানে eventual update চলবে না।

`Strong Consistency` টপিকটা এমন guarantee নিয়ে কাজ করে যেখানে read করার সময় system এমন data দেবে যেন recent acknowledged write already visible।

এজন্য coordination/quorum/leader-based reads/write acknowledgments-এর মতো mechanism লাগতে পারে, যা latency বাড়াতে পারে এবং partition-এ availability কমাতে পারে।

তাই strong consistency সাধারণত সব endpoint-এ ব্যবহার করা হয় না; business-critical invariants-এ ব্যবহার করা হয়।

সহজ করে বললে `Strong Consistency` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: Strong কনসিসটেন্সি means reads reflect the latest successful write according to the system’s chosen ordering guarantees।

বাস্তব উদাহরণ ভাবতে চাইলে `Amazon`-এর মতো সিস্টেমে `Strong Consistency`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Strong Consistency` আসলে কীভাবে সাহায্য করে?

`Strong Consistency` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- feature/endpoint অনুযায়ী consistency guarantee আলাদা করে define করতে সাহায্য করে।
- staleness, read/write path, replication lag, আর user-visible anomalies স্পষ্ট করতে সাহায্য করে।
- availability/latency বনাম correctness trade-off product behavior-এর সাথে map করতে সহায়তা করে।
- “strong vs eventual” discussion-কে buzzword-এর বদলে concrete API behavior-এ নামিয়ে আনে।

---

### কখন `Strong Consistency` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → Money movement, unique constraints, transactional workflows, lock সার্ভিসগুলো.
- Business value কোথায় বেশি? → এটি simplifies reasoning about correctness জন্য critical operations.
- কোন API/feature-এ strong consistency লাগবে, আর কোথায় eventual চলবে?
- write acknowledgment কোন শর্তে success ধরা হবে (leader/quorum/replica lag)?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: High-volume derived ডেটা যেখানে small staleness হলো acceptable.
- ইন্টারভিউ রেড ফ্ল্যাগ: Requiring স্ট্রং কনসিসটেন্সি everywhere ছাড়া discussing ল্যাটেন্সি/SLO impact.
- Assuming স্ট্রং কনসিসটেন্সি implies high পারফরম্যান্স হলো impossible.
- Ignoring scope (per key, per পার্টিশন, global).
- Confusing transactional isolation levels সাথে distributed কনসিসটেন্সি guarantees.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Strong Consistency` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

---

### মন্টুর কেস (ধাপে ধাপে)

- ধাপ ১: critical write request এলো (payment/subscription/inventory)।
- ধাপ ২: system coordination rules অনুযায়ী write commit করল।
- ধাপ ৩: commit guarantee না পাওয়া পর্যন্ত success response delay হতে পারে।
- ধাপ ৪: subsequent reads same consistency path দিয়ে গেলে fresh state দেখাবে।
- ধাপ ৫: partition/latency spike হলে availability impact কী হবে - আগে থেকেই policy ঠিক করতে হয়।

---

### এই টপিকে মন্টু কী সিদ্ধান্ত নিচ্ছে?

- কোন API/feature-এ strong consistency লাগবে, আর কোথায় eventual চলবে?
- write acknowledgment কোন শর্তে success ধরা হবে (leader/quorum/replica lag)?
- user-facing behavior কী হবে: stale data accept করবেন, নাকি latency বাড়িয়ে fresh data দেবেন?

---

## এক লাইনে

- `Strong Consistency` এমন guarantee-কেন্দ্রিক টপিক যেখানে reads/writes-এ latest acknowledged state দেখানোর দিকে জোর দেওয়া হয়।
- এই টপিকে বারবার আসতে পারে: latest read guarantee, coordination, quorum/leader reads, latency trade-off, critical workflows

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Strong Consistency` ডেটা update-এর visibility guarantee, user-visible correctness expectation, আর consistency-level trade-off বোঝায়।

- স্ট্রং কনসিসটেন্সি মানে reads reflect the latest successful write according to the সিস্টেম’s chosen ordering guarantees.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: replication/read-write path আলাদা হলে কোন data কখন visible হবে সেটা define না করলে user-visible inconsistency তৈরি হয়।

- এটি simplifies reasoning about correctness জন্য critical operations.
- এটি রোধ করে ইউজার-visible anomalies যা পারে cause financial অথবা legal issues.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: endpoint/feature অনুযায়ী guarantee আলাদা করে, acceptable staleness ও partition behavior define করে design করা senior-level insight।

- স্ট্রং কনসিসটেন্সি usually requires synchronous coordination (leader confirmation, quorum reads/writes, consensus).
- এটি increases ল্যাটেন্সি এবং পারে কমাতে অ্যাভেইলেবিলিটি সময় পার্টিশনগুলো.
- Compare it সাথে ইভেন্টুয়াল কনসিসটেন্সি: simpler application logic, but higher infrastructure এবং coordination খরচ.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Strong Consistency` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Amazon** order payment অথরাইজেশন এবং inventory reservation অনেক সময় need stronger guarantees than product detail reads.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Strong Consistency` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: Money movement, unique constraints, transactional workflows, lock সার্ভিসগুলো.
- কখন ব্যবহার করবেন না: High-volume derived ডেটা যেখানে small staleness হলো acceptable.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"How would আপনি provide স্ট্রং কনসিসটেন্সি জুড়ে রিজিয়নগুলো, এবং what does it খরচ?\"
- রেড ফ্ল্যাগ: Requiring স্ট্রং কনসিসটেন্সি everywhere ছাড়া discussing ল্যাটেন্সি/SLO impact.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Strong Consistency`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Assuming স্ট্রং কনসিসটেন্সি implies high পারফরম্যান্স হলো impossible.
- Ignoring scope (per key, per পার্টিশন, global).
- Confusing transactional isolation levels সাথে distributed কনসিসটেন্সি guarantees.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Requiring স্ট্রং কনসিসটেন্সি everywhere ছাড়া discussing ল্যাটেন্সি/SLO impact.
- কমন ভুল এড়ান: Assuming স্ট্রং কনসিসটেন্সি implies high পারফরম্যান্স হলো impossible.
- Consistency টপিকে endpoint-by-endpoint guarantee (read-after-write, eventual, strong) বললে উত্তর অনেক পরিষ্কার হয়।
- কেন দরকার (শর্ট নোট): এটি simplifies reasoning about correctness জন্য critical operations.
