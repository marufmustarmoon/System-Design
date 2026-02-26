# HTTP — বাংলা ব্যাখ্যা

_টপিক নম্বর: 073_

## গল্পে বুঝি

মন্টু মিয়াঁর public API web/mobile client থেকে আসে; interoperability, tooling, caching, and debugging-এর জন্য HTTP খুব common choice।

`HTTP` টপিকটা HTTP request/response semantics, status codes, headers, caching, and transport behavior interview context-এ বোঝায়।

HTTP-based design বললে শুধু method names না; timeouts, retries, idempotency, cache-control, authentication, and observability ভাবতে হয়।

ভালো answer-এ আপনি HTTP-কে application protocol হিসেবে explain করবেন, raw transport alternative-এর সাথে context অনুযায়ী compare করবেন।

সহজ করে বললে `HTTP` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: HTTP is an application-layer protocol for request-response communication, widely used on the web and in APIs।

বাস্তব উদাহরণ ভাবতে চাইলে `Amazon`-এর মতো সিস্টেমে `HTTP`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `HTTP` আসলে কীভাবে সাহায্য করে?

`HTTP` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- communication style/protocol choice-কে workload requirement (latency, compatibility, reliability) এর সাথে map করতে সাহায্য করে।
- timeout, retry, idempotency, versioning, আর error semantics design discussion-এ আনতে সাহায্য করে।
- public API বনাম internal service call-এর protocol choice আলাদা করার যুক্তি দেয়।
- debugging/tooling/observability impact explain করলে protocol decision আরও বাস্তবসম্মত হয়।

---

### কখন `HTTP` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → Public APIs, web/mobile backends, interoperable সার্ভিস interfaces.
- Business value কোথায় বেশি? → এটি provides a standard, interoperable way জন্য ক্লায়েন্টগুলো এবং সার্ভারগুলো to exchange resources এবং metadata.
- public API আর internal service call-এ একই protocol লাগবে নাকি আলাদা?
- timeout, retry, idempotency, versioning কীভাবে handle করবেন?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: Ultra-low-ল্যাটেন্সি binary internal RPC paths যেখানে HTTP+JSON overhead হলো unnecessary.
- ইন্টারভিউ রেড ফ্ল্যাগ: Designing APIs ছাড়া status-code semantics, timeouts, অথবা idempotency considerations.
- Treating HTTP as inherently synchronous (async workflows পারে still ব্যবহার HTTP).
- Misusing methods (`GET` সাথে side effects).
- Ignoring ক্যাশ headers এবং conditional রিকোয়েস্টগুলো.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `HTTP` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

---

### মন্টুর কেস (ধাপে ধাপে)

- ধাপ ১: endpoint contract (method/path/status) define করুন।
- ধাপ ২: timeout/retry/idempotency rules ঠিক করুন।
- ধাপ ৩: headers/cache/auth/versioning strategy দিন।
- ধাপ ৪: error model ও rate limiting যোগ করুন।
- ধাপ ৫: logs/trace/correlation ID observability যোগ করুন।

---

### এই টপিকে মন্টু কী সিদ্ধান্ত নিচ্ছে?

- public API আর internal service call-এ একই protocol লাগবে নাকি আলাদা?
- timeout, retry, idempotency, versioning কীভাবে handle করবেন?
- debugging/tooling/compatibility-এর দিক থেকে এই protocol বেছে নেওয়ার কারণ কী?

---

## এক লাইনে

- `HTTP` client/service communication protocol বা API style বাছাইয়ে semantics, latency, reliability, ও compatibility trade-off বোঝায়।
- এই টপিকে বারবার আসতে পারে: methods/status codes, headers, timeouts, cache-control, idempotency

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `HTTP` services/clients-এর communication contract, semantics, এবং network behavior বোঝার টপিক।

- HTTP হলো an application-layer protocol জন্য রিকোয়েস্ট-রেসপন্স communication, widely used on the web এবং in APIs.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: একই communication style সব workload-এ fit করে না; latency, compatibility, reliability অনুযায়ী protocol/API design দরকার।

- এটি provides a standard, interoperable way জন্য ক্লায়েন্টগুলো এবং সার্ভারগুলো to exchange resources এবং metadata.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: timeout, retry, idempotency, versioning, error semantics, এবং observability plan ছাড়া protocol discussion অসম্পূর্ণ থাকে।

- HTTP defines methods, headers, status codes, এবং semantics; it commonly runs উপর TCP (অথবা QUIC জন্য HTTP/3).
- এটি হলো easy to adopt এবং tooling-rich, but header overhead এবং রিকোয়েস্ট-রেসপন্স patterns may হতে less efficient জন্য some internal RPC workloads.
- HTTP এছাড়াও সক্ষম করে caching এবং CDN integration, যা হলো a major practical advantage in সিস্টেম design.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `HTTP` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Amazon** public APIs এবং websites ব্যবহার HTTP জন্য browser এবং mobile communication, সাথে caching এবং CDN সাপোর্ট at the edge.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `HTTP` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: Public APIs, web/mobile backends, interoperable সার্ভিস interfaces.
- কখন ব্যবহার করবেন না: Ultra-low-ল্যাটেন্সি binary internal RPC paths যেখানে HTTP+JSON overhead হলো unnecessary.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"What HTTP methods এবং status codes would আপনি ব্যবহার জন্য এটি API?\"
- রেড ফ্ল্যাগ: Designing APIs ছাড়া status-code semantics, timeouts, অথবা idempotency considerations.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `HTTP`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Treating HTTP as inherently synchronous (async workflows পারে still ব্যবহার HTTP).
- Misusing methods (`GET` সাথে side effects).
- Ignoring ক্যাশ headers এবং conditional রিকোয়েস্টগুলো.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Designing APIs ছাড়া status-code semantics, timeouts, অথবা idempotency considerations.
- কমন ভুল এড়ান: Treating HTTP as inherently synchronous (async workflows পারে still ব্যবহার HTTP).
- Routing/communication টপিকে latency, retry behavior, এবং observability উল্লেখ করুন।
- কেন দরকার (শর্ট নোট): এটি provides a standard, interoperable way জন্য ক্লায়েন্টগুলো এবং সার্ভারগুলো to exchange resources এবং metadata.
