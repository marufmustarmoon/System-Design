# Master-Master — বাংলা ব্যাখ্যা

_টপিক নম্বর: 020_

## গল্পে বুঝি

মন্টু মিয়াঁ `Master-Master` ধরনের replication model শিখছেন কারণ সব replica একই role পালন করে না। কারা write নেবে, কারা read serve করবে - এটা design-এর গুরুত্বপূর্ণ অংশ।

Single-writer model-এ write path সহজ হতে পারে কিন্তু writer bottleneck/ failover challenge থাকে। Multi-writer model-এ availability বাড়তে পারে কিন্তু conflict resolution কঠিন হয়।

বাস্তব সিস্টেমে model নির্বাচন product invariants, write contention, geo-distribution, এবং operational maturity-এর উপর নির্ভর করে।

এই টপিকে interviewer সাধারণত conflict, failover, lag, consistency নিয়ে follow-up করে।

সহজ করে বললে `Master-Master` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: Master-master (multi-leader) রেপ্লিকেশন allows writes on more than one node, then synchronizes changes between them।

বাস্তব উদাহরণ ভাবতে চাইলে `WhatsApp`-এর মতো সিস্টেমে `Master-Master`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Master-Master` আসলে কীভাবে সাহায্য করে?

`Master-Master` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- টপিকটি কোন problem solve করে এবং কোন requirement-এ value দেয়—সেটা পরিষ্কার করতে সাহায্য করে।
- behavior, trade-off, limitation, আর user impact একসাথে design answer-এ আনতে সহায়তা করে।
- diagram/term-এর বাইরে operational implication explain করতে সাহায্য করে।
- interview answer-কে context-aware ও defensible করতে কাঠামো দেয়।

---

### কখন `Master-Master` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → রিজিয়ন-local writes সাথে AP-friendly অথবা mergeable ডেটা.
- Business value কোথায় বেশি? → এটি সাপোর্ট করে geographically distributed writes এবং কমায় dependency on a single writable node.
- failure domain কী: instance, AZ, region, dependency, deployment?
- failure detect করার signal কী, এবং automatic reaction কী হবে?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: Financial transactions অথবা strict ordering requirements ছাড়া strong coordination.
- ইন্টারভিউ রেড ফ্ল্যাগ: Choosing মাস্টার-মাস্টার to "scale writes" ছাড়া explaining conflict semantics.
- Assuming ডাটাবেজ engine magically resolves all conflicts correctly.
- Ignoring clock skew যদি ব্যবহার করে timestamps.
- ব্যবহার করে multi-leader যেখানে business rules require a single authoritative order.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Master-Master` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

---

### মন্টুর কেস (ধাপে ধাপে)

- ধাপ ১: writer topology ঠিক করুন (single vs multi)।
- ধাপ ২: read routing ও lag-aware reads policy নির্ধারণ করুন।
- ধাপ ৩: failover/switchover কীভাবে হবে বলুন।
- ধাপ ৪: conflict/duplicate writes (multi-writer হলে) handle করুন।
- ধাপ ৫: operational tooling/monitoring requirement উল্লেখ করুন।

---

### এই টপিকে মন্টু কী সিদ্ধান্ত নিচ্ছে?

- failure domain কী: instance, AZ, region, dependency, deployment?
- failure detect করার signal কী, এবং automatic reaction কী হবে?
- degrade mode, failover, retry, throttling - কোনটা কখন চালু হবে?

---

## এক লাইনে

- `Master-Master` সিস্টেম ডিজাইনের একটি গুরুত্বপূর্ণ ধারণা, যা requirement, behavior, এবং trade-off মিলিয়ে design decision নিতে সাহায্য করে।
- এই টপিকে বারবার আসতে পারে: master, use case, trade-off, failure case

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Master-Master` টপিকটি requirement, behavior, আর trade-off connect করে design decision নেওয়ার ধারণা পরিষ্কার করে।

- মাস্টার-মাস্টার (multi-leader) রেপ্লিকেশন অনুমতি দেয় writes on more than one node, then synchronizes changes মাঝে them.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: বাস্তব সিস্টেমে scale, cost, correctness, এবং operational complexity সামলাতে এই ধারণা/প্যাটার্ন দরকার হয়।

- এটি সাপোর্ট করে geographically distributed writes এবং কমায় dependency on a single writable node.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: internals-এর সাথে user-visible behavior, trade-off, এবং operational impact একসাথে ব্যাখ্যা করলে sectionটি শক্তিশালী হয়।

- Each leader accepts writes locally এবং replicates to others.
- এই hard part হলো conflict detection/resolution, especially জন্য concurrent updates to the same entity.
- Compared সাথে primary-replica, multi-leader পারে উন্নত করতে write locality/অ্যাভেইলেবিলিটি but increases correctness complexity.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Master-Master` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **WhatsApp**-style globally distributed metadata সার্ভিসগুলো may ব্যবহার multi-writer strategies শুধু জন্য carefully chosen ডেটা types যেখানে conflicts হলো manageable.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Master-Master` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: রিজিয়ন-local writes সাথে AP-friendly অথবা mergeable ডেটা.
- কখন ব্যবহার করবেন না: Financial transactions অথবা strict ordering requirements ছাড়া strong coordination.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"What conflict resolution strategy would আপনি ব্যবহার জন্য concurrent updates?\"
- রেড ফ্ল্যাগ: Choosing মাস্টার-মাস্টার to "scale writes" ছাড়া explaining conflict semantics.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Master-Master`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Assuming ডাটাবেজ engine magically resolves all conflicts correctly.
- Ignoring clock skew যদি ব্যবহার করে timestamps.
- ব্যবহার করে multi-leader যেখানে business rules require a single authoritative order.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Choosing মাস্টার-মাস্টার to "scale writes" ছাড়া explaining conflict semantics.
- কমন ভুল এড়ান: Assuming ডাটাবেজ engine magically resolves all conflicts correctly.
- Data path ও consistency expectation আগে বললে বাকি ডিজাইন explain করা সহজ হয়।
- কেন দরকার (শর্ট নোট): এটি সাপোর্ট করে geographically distributed writes এবং কমায় dependency on a single writable node.
