# gRPC — বাংলা ব্যাখ্যা

_টপিক নম্বর: 079_

## গল্পে বুঝি

মন্টু মিয়াঁ internal service-to-service communication-এ typed contract, fast serialization, এবং strong tooling চান।

`gRPC` টপিকটা RPC-style communication বোঝায় যেখানে remote call-কে local function call-এর মতো model করা হয়, কিন্তু network failure reality ভুললে সমস্যা হয়।

Typed schemas/protobuf/IDL approach development speed বাড়াতে পারে, তবে compatibility, retries, timeouts, and observability design করতে হয়।

ইন্টারভিউতে RPC/gRPC বললে synchronous coupling ও failure propagation কিভাবে handle করবেন সেটা বললে maturity বোঝায়।

সহজ করে বললে `gRPC` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: gRPC is a high-পারফরম্যান্স RPC framework using Protocol Buffers and HTTP/2, with strong typing and streaming support।

বাস্তব উদাহরণ ভাবতে চাইলে `Netflix, Google`-এর মতো সিস্টেমে `gRPC`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `gRPC` আসলে কীভাবে সাহায্য করে?

`gRPC` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- service-to-service communication-এ typed contracts, fast serialization, এবং clear RPC semantics explain করতে সাহায্য করে।
- deadline/timeout/retry/idempotency policy protocol choice-এর সাথে align করতে সাহায্য করে।
- IDL/protobuf-based compatibility planning (versioning/backward compatibility) discuss করতে সুবিধা দেয়।
- network failure-কে local function call-এর মতো treat করার ভুল এড়াতে সাহায্য করে।

---

### কখন `gRPC` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → Internal microservices, low-ল্যাটেন্সি paths, streaming, strongly typed contracts.
- Business value কোথায় বেশি? → এটি উন্নত করে efficiency এবং developer ergonomics জন্য internal সার্ভিস-টু-সার্ভিস APIs at scale.
- public API আর internal service call-এ একই protocol লাগবে নাকি আলাদা?
- timeout, retry, idempotency, versioning কীভাবে handle করবেন?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: Public APIs needing easy curl/browser access এবং broad third-party সাপোর্ট.
- ইন্টারভিউ রেড ফ্ল্যাগ: Choosing gRPC ছাড়া a plan জন্য observability, versioning, এবং external compatibility.
- Assuming gRPC removes the need জন্য রিট্রাইগুলো/timeouts/idempotency.
- Poor protobuf evolution (breaking field changes).
- Ignoring operational overhead of codegen এবং ক্লায়েন্ট version coordination.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `gRPC` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

---

### মন্টুর কেস (ধাপে ধাপে)

- ধাপ ১: service contract/IDL define করুন।
- ধাপ ২: deadline/timeout/retry policy নির্ধারণ করুন।
- ধাপ ৩: error model ও idempotency semantics পরিষ্কার করুন।
- ধাপ ৪: versioning/backward compatibility পরিকল্পনা করুন।
- ধাপ ৫: tracing/metrics/logging integration রাখুন।

---

### এই টপিকে মন্টু কী সিদ্ধান্ত নিচ্ছে?

- public API আর internal service call-এ একই protocol লাগবে নাকি আলাদা?
- timeout, retry, idempotency, versioning কীভাবে handle করবেন?
- debugging/tooling/compatibility-এর দিক থেকে এই protocol বেছে নেওয়ার কারণ কী?

---

## এক লাইনে

- `gRPC` client/service communication protocol বা API style বাছাইয়ে semantics, latency, reliability, ও compatibility trade-off বোঝায়।
- এই টপিকে বারবার আসতে পারে: IDL/protobuf, deadlines/timeouts, streaming, backward compatibility, service-to-service

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `gRPC` services/clients-এর communication contract, semantics, এবং network behavior বোঝার টপিক।

- gRPC হলো a high-পারফরম্যান্স RPC framework ব্যবহার করে Protocol Buffers এবং HTTP/2, সাথে strong typing এবং streaming সাপোর্ট.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: একই communication style সব workload-এ fit করে না; latency, compatibility, reliability অনুযায়ী protocol/API design দরকার।

- এটি উন্নত করে efficiency এবং developer ergonomics জন্য internal সার্ভিস-টু-সার্ভিস APIs at scale.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: timeout, retry, idempotency, versioning, error semantics, এবং observability plan ছাড়া protocol discussion অসম্পূর্ণ থাকে।

- সার্ভিসগুলো define protobuf contracts; codegen produces ক্লায়েন্ট/সার্ভার stubs.
- HTTP/2 multiplexing এবং binary serialization উন্নত করতে থ্রুপুট/ল্যাটেন্সি compared সাথে many HTTP+JSON setups.
- Compared সাথে REST, gRPC offers stronger typing এবং streaming but হলো less browser-friendly এবং harder জন্য some external কনজিউমারগুলো.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `gRPC` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Netflix** অথবা **Google** internal microservices পারে ব্যবহার gRPC জন্য low-ল্যাটেন্সি, typed communication এবং streaming RPCs.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `gRPC` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: Internal microservices, low-ল্যাটেন্সি paths, streaming, strongly typed contracts.
- কখন ব্যবহার করবেন না: Public APIs needing easy curl/browser access এবং broad third-party সাপোর্ট.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"Why would আপনি choose gRPC উপর REST জন্য internal সার্ভিস calls?\"
- রেড ফ্ল্যাগ: Choosing gRPC ছাড়া a plan জন্য observability, versioning, এবং external compatibility.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `gRPC`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Assuming gRPC removes the need জন্য রিট্রাইগুলো/timeouts/idempotency.
- Poor protobuf evolution (breaking field changes).
- Ignoring operational overhead of codegen এবং ক্লায়েন্ট version coordination.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Choosing gRPC ছাড়া a plan জন্য observability, versioning, এবং external compatibility.
- কমন ভুল এড়ান: Assuming gRPC removes the need জন্য রিট্রাইগুলো/timeouts/idempotency.
- Routing/communication টপিকে latency, retry behavior, এবং observability উল্লেখ করুন।
- কেন দরকার (শর্ট নোট): এটি উন্নত করে efficiency এবং developer ergonomics জন্য internal সার্ভিস-টু-সার্ভিস APIs at scale.
