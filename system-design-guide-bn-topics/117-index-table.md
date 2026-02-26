# Index Table — বাংলা ব্যাখ্যা

_টপিক নম্বর: 117_

## গল্পে বুঝি

`Index Table` এমন একটি system/cloud design pattern যা নির্দিষ্ট ধরনের recurring problem সমাধানে ব্যবহার করা হয়। মন্টু মিয়াঁর জন্য pattern মুখস্থ করার চেয়ে problem-fit বোঝা বেশি জরুরি।

একই pattern ভুল context-এ overengineering হয়ে যেতে পারে, আবার সঠিক context-এ maintenance burden অনেক কমিয়ে দেয়।

Pattern discussion-এ interviewer সাধারণত জানতে চায়: problem statement কী, flow কী, trade-off কী, failure case কী।

তাই `Index Table` explain করার সময় components + data flow + misuse case একসাথে বললে clarity আসে।

সহজ করে বললে `Index Table` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: An index table is an additional table/store optimized for a specific lookup path (for example, lookup by email to user ID)।

বাস্তব উদাহরণ ভাবতে চাইলে `Amazon`-এর মতো সিস্টেমে `Index Table`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Index Table` আসলে কীভাবে সাহায্য করে?

`Index Table` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- data model, access pattern, query path, আর scale requirement মিলিয়ে storage strategy explain করতে সাহায্য করে।
- indexing/replication/partitioning/sharding-এর দরকার কোথায় এবং কেন—সেটা স্পষ্ট করতে সহায়তা করে।
- consistency বনাম query flexibility বনাম operational complexity trade-off পরিষ্কার করে।
- database choice-কে brand preference নয়, workload-driven decision হিসেবে দেখাতে সাহায্য করে।

---

### কখন `Index Table` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → Alternate key lookups in NoSQL stores অথবা read models.
- Business value কোথায় বেশি? → Primary ডেটা models অনেক সময় optimize one access path; সিস্টেমগুলো need fast alternate lookups ছাড়া full scans.
- এই টপিক কোন সমস্যা solve করে - এক লাইনে সেটা কি পরিষ্কার?
- এর core flow/component/assumption কী?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: Simple relational workloads যেখানে native ইনডেক্সগুলো হলো sufficient.
- ইন্টারভিউ রেড ফ্ল্যাগ: Adding ইনডেক্স tables ছাড়া describing write/update flow.
- Forgetting to update/delete secondary ইনডেক্স entries.
- কোনো recovery process জন্য ইনডেক্স drift.
- Overbuilding many ইনডেক্সগুলো এবং hurting write থ্রুপুট.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Index Table` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

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

- `Index Table` নির্দিষ্ট recurring architecture problem সমাধানের reusable design pattern এবং তার trade-off বোঝায়।
- এই টপিকে বারবার আসতে পারে: index, table, use case, trade-off, failure case

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Index Table` একটি reusable design pattern, যা recurring problem সমাধানে tested architectural approach দেয়।

- একটি ইনডেক্স table হলো an additional table/store optimized জন্য a specific lookup path (জন্য example, lookup by email to ইউজার ID).

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: Recurring problem বারবার ad-hoc ভাবে solve না করে tested pattern ব্যবহার করলে risk কমে ও design আলোচনা স্পষ্ট হয়।

- Primary ডেটা models অনেক সময় optimize one access path; সিস্টেমগুলো need fast alternate lookups ছাড়া full scans.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: pattern apply করার সময় actors/flow, benefits, costs, failure cases, আর migration path একসাথে ব্যাখ্যা করতে হয়।

- Writes update both the primary record এবং one অথবা more ইনডেক্স tables (synchronously অথবা asynchronously).
- ইনডেক্স tables উন্নত করতে query পারফরম্যান্স but add write amplification এবং কনসিসটেন্সি maintenance.
- Compared সাথে DB-native ইনডেক্সগুলো, ইনডেক্স tables হলো application-managed এবং পারে span সিস্টেমগুলো অথবা denormalized keys.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Index Table` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Amazon** may maintain separate lookup structures জন্য product SKU, seller ID, এবং category access paths.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Index Table` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: Alternate key lookups in NoSQL stores অথবা read models.
- কখন ব্যবহার করবেন না: Simple relational workloads যেখানে native ইনডেক্সগুলো হলো sufficient.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"How do আপনি keep an ইনডেক্স table consistent সাথে the source record?\"
- রেড ফ্ল্যাগ: Adding ইনডেক্স tables ছাড়া describing write/update flow.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Index Table`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Forgetting to update/delete secondary ইনডেক্স entries.
- কোনো recovery process জন্য ইনডেক্স drift.
- Overbuilding many ইনডেক্সগুলো এবং hurting write থ্রুপুট.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Adding ইনডেক্স tables ছাড়া describing write/update flow.
- কমন ভুল এড়ান: Forgetting to update/delete secondary ইনডেক্স entries.
- Data path ও consistency expectation আগে বললে বাকি ডিজাইন explain করা সহজ হয়।
- কেন দরকার (শর্ট নোট): Primary ডেটা models অনেক সময় optimize one access path; সিস্টেমগুলো need fast alternate lookups ছাড়া full scans.
