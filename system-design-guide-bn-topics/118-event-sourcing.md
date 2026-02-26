# Event Sourcing — বাংলা ব্যাখ্যা

_টপিক নম্বর: 118_

## গল্পে বুঝি

`Event Sourcing` এমন একটি system/cloud design pattern যা নির্দিষ্ট ধরনের recurring problem সমাধানে ব্যবহার করা হয়। মন্টু মিয়াঁর জন্য pattern মুখস্থ করার চেয়ে problem-fit বোঝা বেশি জরুরি।

একই pattern ভুল context-এ overengineering হয়ে যেতে পারে, আবার সঠিক context-এ maintenance burden অনেক কমিয়ে দেয়।

Pattern discussion-এ interviewer সাধারণত জানতে চায়: problem statement কী, flow কী, trade-off কী, failure case কী।

তাই `Event Sourcing` explain করার সময় components + data flow + misuse case একসাথে বললে clarity আসে।

সহজ করে বললে `Event Sourcing` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: Event sourcing stores state changes as an append-only sequence of events, and current state is reconstructed from those events।

বাস্তব উদাহরণ ভাবতে চাইলে `Uber, Amazon`-এর মতো সিস্টেমে `Event Sourcing`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Event Sourcing` আসলে কীভাবে সাহায্য করে?

`Event Sourcing` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- data model, access pattern, query path, আর scale requirement মিলিয়ে storage strategy explain করতে সাহায্য করে।
- indexing/replication/partitioning/sharding-এর দরকার কোথায় এবং কেন—সেটা স্পষ্ট করতে সহায়তা করে।
- consistency বনাম query flexibility বনাম operational complexity trade-off পরিষ্কার করে।
- database choice-কে brand preference নয়, workload-driven decision হিসেবে দেখাতে সাহায্য করে।

---

### কখন `Event Sourcing` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → Auditable workflows, temporal queries, complex domain স্টেট machines.
- Business value কোথায় বেশি? → এটি provides a full অডিট trail, temporal history, এবং replay capability জন্য complex business workflows.
- এই টপিক কোন সমস্যা solve করে - এক লাইনে সেটা কি পরিষ্কার?
- এর core flow/component/assumption কী?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: Simple CRUD সিস্টেমগুলো সাথে no replay/history need.
- ইন্টারভিউ রেড ফ্ল্যাগ: Choosing ইভেন্ট সোর্সিং জন্য a simple CRUD app "কারণ it হলো scalable."
- Treating emitted integration ইভেন্টগুলো এবং ইভেন্ট-sourcing domain ইভেন্টগুলো as the same thing.
- কোনো snapshotting strategy জন্য long ইভেন্ট streams.
- Underestimating projection rebuild এবং schema migration complexity.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Event Sourcing` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

---

### মন্টুর কেস (ধাপে ধাপে)

- ধাপ ১: pattern যে সমস্যা solve করে সেটা পরিষ্কার করুন।
- ধাপ ২: core components/actors/flow ব্যাখ্যা করুন।
- ধাপ ৩: benefits ও costs বলুন।
- ধাপ ৪: failure/misuse cases বলুন।
- ধাপ ৫: বিকল্প pattern-এর সাথে তুলনা করুন।

---

### এই টপিকে মন্টু কী সিদ্ধান্ত নিচ্ছে?

- এই টপিক কোন সমস্যা solve করে - এক লাইনে সেটা কি পরিষ্কার?
- এর core flow/component/assumption কী?
- কোন trade-off বা limitation জানালে উত্তর বাস্তবসম্মত হবে?

---

## এক লাইনে

- `Event Sourcing` নির্দিষ্ট recurring architecture problem সমাধানের reusable design pattern এবং তার trade-off বোঝায়।
- এই টপিকে বারবার আসতে পারে: append-only log, event replay, projection rebuild, audit trail, versioned events

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Event Sourcing` একটি reusable design pattern, যা recurring problem সমাধানে tested architectural approach দেয়।

- ইভেন্ট সোর্সিং stores স্টেট changes as an append-শুধু sequence of ইভেন্টগুলো, এবং current স্টেট হলো reconstructed from those ইভেন্টগুলো.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: Recurring problem বারবার ad-hoc ভাবে solve না করে tested pattern ব্যবহার করলে risk কমে ও design আলোচনা স্পষ্ট হয়।

- এটি provides a full অডিট trail, temporal history, এবং replay capability জন্য complex business workflows.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: pattern apply করার সময় actors/flow, benefits, costs, failure cases, আর migration path একসাথে ব্যাখ্যা করতে হয়।

- এই ইভেন্ট log হলো the source of truth; projections/ম্যাটেরিয়ালাইজড ভিউs derive current/read models.
- এটি সক্ষম করে replay এবং debugging, but schema evolution, versioning, এবং projection rebuilds হলো operationally complex.
- Compare সাথে CRUD persistence: ইভেন্ট সোর্সিং উন্নত করে history/replay but adds complexity জন্য simple domains.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Event Sourcing` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Uber**-like trip lifecycle অথবা **Amazon** order স্টেট transitions পারে benefit from ইভেন্ট logs যখন auditability এবং replay matter.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Event Sourcing` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: Auditable workflows, temporal queries, complex domain স্টেট machines.
- কখন ব্যবহার করবেন না: Simple CRUD সিস্টেমগুলো সাথে no replay/history need.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"How would আপনি evolve ইভেন্ট schemas ছাড়া breaking replays?\"
- রেড ফ্ল্যাগ: Choosing ইভেন্ট সোর্সিং জন্য a simple CRUD app "কারণ it হলো scalable."

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Event Sourcing`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Treating emitted integration ইভেন্টগুলো এবং ইভেন্ট-sourcing domain ইভেন্টগুলো as the same thing.
- কোনো snapshotting strategy জন্য long ইভেন্ট streams.
- Underestimating projection rebuild এবং schema migration complexity.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Choosing ইভেন্ট সোর্সিং জন্য a simple CRUD app "কারণ it হলো scalable."
- কমন ভুল এড়ান: Treating emitted integration ইভেন্টগুলো এবং ইভেন্ট-sourcing domain ইভেন্টগুলো as the same thing.
- Data path ও consistency expectation আগে বললে বাকি ডিজাইন explain করা সহজ হয়।
- কেন দরকার (শর্ট নোট): এটি provides a full অডিট trail, temporal history, এবং replay capability জন্য complex business workflows.
