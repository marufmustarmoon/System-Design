# Communication — বাংলা ব্যাখ্যা

_টপিক নম্বর: 072_

## গল্পে বুঝি

মন্টু মিয়াঁ `Communication` টপিকটি পড়ে বুঝতে চান এটি তার system design decision-এ কোথায় বসে।

এই ধরনের টপিক ছোট দেখালেও অনেক সময় architecture-র একটি critical trade-off বা operational concern represent করে।

ইন্টারভিউতে definition বলার পরে practical scenario দিলে topic দ্রুত পরিষ্কার হয় - তাই story-driven explanation useful।

মন্টুর লক্ষ্য হলো `Communication`-কে শুধু টার্ম হিসেবে না দেখে decision tool হিসেবে ব্যবহার করা।

সহজ করে বললে `Communication` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: Communication patterns define how components exchange data and commands across a system।

বাস্তব উদাহরণ ভাবতে চাইলে `Google`-এর মতো সিস্টেমে `Communication`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Communication` আসলে কীভাবে সাহায্য করে?

`Communication` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- communication style/protocol choice-কে workload requirement (latency, compatibility, reliability) এর সাথে map করতে সাহায্য করে।
- timeout, retry, idempotency, versioning, আর error semantics design discussion-এ আনতে সাহায্য করে।
- public API বনাম internal service call-এর protocol choice আলাদা করার যুক্তি দেয়।
- debugging/tooling/observability impact explain করলে protocol decision আরও বাস্তবসম্মত হয়।

---

### কখন `Communication` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → In every design যেখানে components interact জুড়ে process/network boundaries.
- Business value কোথায় বেশি? → Protocol এবং API style choices directly affect ল্যাটেন্সি, reliability, compatibility, এবং টিম velocity.
- public API আর internal service call-এ একই protocol লাগবে নাকি আলাদা?
- timeout, retry, idempotency, versioning কীভাবে handle করবেন?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: করবেন না উপর-discuss protocol internals যদি the interview হলো focused on ডেটা modeling unless communication হলো the bottleneck.
- ইন্টারভিউ রেড ফ্ল্যাগ: Mixing protocol terms এবং API styles as যদি they হলো equivalent.
- Confusing HTTP সাথে REST.
- Ignoring timeout/রিট্রাই/idempotency behavior.
- Choosing one protocol style globally জন্য unrelated workloads.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Communication` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

---

### মন্টুর কেস (ধাপে ধাপে)

- ধাপ ১: topic-এর problem/use-case নির্ধারণ করুন।
- ধাপ ২: core flow/components বোঝান।
- ধাপ ৩: trade-off/failure cases বলুন।
- ধাপ ৪: কখন ব্যবহার করবেন/করবেন না বলুন।
- ধাপ ৫: real system example-এর সাথে connect করুন।

---

### এই টপিকে মন্টু কী সিদ্ধান্ত নিচ্ছে?

- public API আর internal service call-এ একই protocol লাগবে নাকি আলাদা?
- timeout, retry, idempotency, versioning কীভাবে handle করবেন?
- debugging/tooling/compatibility-এর দিক থেকে এই protocol বেছে নেওয়ার কারণ কী?

---

## এক লাইনে

- `Communication` client/service communication protocol বা API style বাছাইয়ে semantics, latency, reliability, ও compatibility trade-off বোঝায়।
- এই টপিকে বারবার আসতে পারে: communication, use case, trade-off, failure case, operations

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Communication` services/clients-এর communication contract, semantics, এবং network behavior বোঝার টপিক।

- Communication patterns define how components exchange ডেটা এবং commands জুড়ে a সিস্টেম.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: একই communication style সব workload-এ fit করে না; latency, compatibility, reliability অনুযায়ী protocol/API design দরকার।

- Protocol এবং API style choices directly affect ল্যাটেন্সি, reliability, compatibility, এবং টিম velocity.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: timeout, retry, idempotency, versioning, error semantics, এবং observability plan ছাড়া protocol discussion অসম্পূর্ণ থাকে।

- এই right communication choice depends on ট্রাফিক shape, payload size, streaming needs, coupling tolerance, এবং ফেইলিউর হ্যান্ডলিং.
- Senior designs separate transport concerns (TCP/UDP), protocol concerns (HTTP), এবং API style (REST/gRPC/GraphQL/RPC).
- Interviewers look জন্য deliberate choices, না defaulting every সার্ভিস to one style.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Communication` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Google** সিস্টেমগুলো mix HTTP/REST জন্য external APIs এবং gRPC/RPC জন্য internal low-ল্যাটেন্সি সার্ভিস-টু-সার্ভিস communication.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Communication` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: In every design যেখানে components interact জুড়ে process/network boundaries.
- কখন ব্যবহার করবেন না: করবেন না উপর-discuss protocol internals যদি the interview হলো focused on ডেটা modeling unless communication হলো the bottleneck.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"Why did আপনি choose REST/gRPC/GraphQL here?\"
- রেড ফ্ল্যাগ: Mixing protocol terms এবং API styles as যদি they হলো equivalent.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Communication`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Confusing HTTP সাথে REST.
- Ignoring timeout/রিট্রাই/idempotency behavior.
- Choosing one protocol style globally জন্য unrelated workloads.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Mixing protocol terms এবং API styles as যদি they হলো equivalent.
- কমন ভুল এড়ান: Confusing HTTP সাথে REST.
- Routing/communication টপিকে latency, retry behavior, এবং observability উল্লেখ করুন।
- কেন দরকার (শর্ট নোট): Protocol এবং API style choices directly affect ল্যাটেন্সি, reliability, compatibility, এবং টিম velocity.
