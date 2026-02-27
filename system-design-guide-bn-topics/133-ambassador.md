# Ambassador — বাংলা ব্যাখ্যা

_টপিক নম্বর: 133_

## গল্পে বুঝি

মুন মিয়াঁর টিম প্রোডাক্ট launch করার পর দেখল, এটি keeps application code simpler এবং standardizes how সার্ভিসগুলো talk to external dependencies।
প্রথম incident-এ মুন ভাবল সমস্যা সহজ: বড় server নিলেই হবে। সে CPU/RAM বাড়াল, machine class upgrade করল, load কিছুদিন কমলও।
কিন্তু এক মাস পর আবার peak hour-এ timeout, queue buildup, আর customer complaint ফিরে এলো। তখন তার confusion: "hardware কম, নাকি design ভুল?"
তদন্তে বোঝা গেল আসল সমস্যা ছিল architecture decision। কারণ dependency coupling, shared state, আর failure handling plan ছাড়া শুধু machine বড় করলে সমস্যা ঘুরে আবার আসে।
এই জায়গায় `Ambassador` সামনে আসে। সহজ ভাষায়, Ambassador is a pattern where a helper proxy/process handles outbound connectivity concerns for an application (service discovery, retries, TLS, routing to external services)।
মুন টিমকে Wrong vs Right decision টেবিল বানাতে বলল:
- Wrong: requirement না বুঝে আগে tool/pattern নির্বাচন
- Wrong: one-box optimization ধরে নেওয়া যে long-term scaling solved
- Right: user impact, SLO, এবং failure domain ধরে design boundary ঠিক করা
- Right: `Ambassador` নিলে কোন metric ভালো হবে (latency/error/cost) আর কোন complexity বাড়বে, আগে থেকেই লিখে রাখা
এতেই business আর tech একসাথে align হলো: কোন feature-এ speed priority, কোন feature-এ correctness priority, আর কোথায় controlled degradation চলবে।
শেষে মুনের টিম ৩টা প্রশ্নের পরিষ্কার উত্তর দাঁড় করাল:
- **"কেন শুধু বড় server কিনলেই হবে না?"** কারণ এতে capacity ceiling, high cost jump, আর single point of failure রয়ে যায়।
- **"কেন বেশি machine কাজে দেয়?"** কারণ load ভাগ করা যায়, parallel processing বাড়ে, এবং failure isolation পাওয়া যায়।
- **"horizontal scaling-এর পর নতুন সমস্যা কী?"** consistency, coordination, observability, rebalancing, এবং distributed debugging-এর মতো নতুন operational challenge আসে।

### `Ambassador` আসলে কীভাবে সাহায্য করে?

`Ambassador` decision-making-কে concrete করে: abstract theory থেকে সরাসরি architecture action-এ নিয়ে আসে।
- requirement -> bottleneck -> design choice mapping পরিষ্কার হয়।
- performance, cost, reliability, complexity - এই চার trade-off একসাথে দেখা যায়।
- junior engineer implementation বুঝতে পারে, senior engineer review board-এ decision defend করতে পারে।
- failure path আগে ধরতে পারলে incident frequency ও blast radius দুইটাই কমে।

### কখন `Ambassador` বেছে নেওয়া সঠিক?

এটি বেছে নিন তখনই, যখন problem statement, SLA/SLO, এবং operational ownership পরিষ্কার।
- strongest signal: Standardizing outbound calls, রিট্রাইগুলো, discovery, এবং TLS জুড়ে many সার্ভিসগুলো।
- business signal: এটি keeps application code simpler এবং standardizes how সার্ভিসগুলো talk to external dependencies।
- choose করবেন যদি monitoring, rollback, এবং runbook maintain করার সক্ষমতা টিমের থাকে।
- choose করবেন না যদি scope এত ছোট হয় যে pattern-এর complexity লাভের চেয়ে বেশি হয়ে যায়।

### কিন্তু কোথায় বিপদ?

`Ambassador` ভুল context-এ নিলে solution-এর বদলে নতুন incident তৈরি করে।
- wrong context: Small সিস্টেমগুলো যেখানে app-native ক্লায়েন্টগুলো হলো simpler এবং sufficient।
- misuse করলে latency বেড়ে যেতে পারে, stale/incorrect output আসতে পারে, বা retry cascade তৈরি হতে পারে।
- interview red flag: Adding an ambassador ছাড়া observability into প্রক্সি রিট্রাইগুলো/timeouts।
- ownership অস্পষ্ট থাকলে incident-এর সময় detection, decision, recovery - সব ধাপ ধীর হয়ে যায়।

### মুনের কেস (ধাপে ধাপে)

- ধাপ ১: business flow থেকে critical path বনাম non-critical path আলাদা করুন।
- ধাপ ২: `Ambassador` design-এর invariant লিখুন: কোনটা ভাঙা যাবে না, কোনটা degrade হতে পারে।
- ধাপ ৩: capacity plan করুন (steady load, burst load, failure load আলাদা করে)।
- ধাপ ৪: guardrail দিন (idempotency, rate control, timeout, retry budget, fallback)।
- ধাপ ৫: load test + failure drill চালিয়ে production readiness validate করুন।

### এই টপিকে মুন কী সিদ্ধান্ত নিচ্ছে?

- service boundary business capability অনুযায়ী ঠিক করা হয়েছে কি?
- data ownership এবং API contract clear কি?
- service decomposition থেকে পাওয়া gain কি operational complexity justify করছে?

## এক লাইনে

- `Ambassador` হলো এমন একটি design lens, যা business requirement আর system behavior-কে একই ফ্রেমে আনে।
- Interview keywords: problem fit, data flow, trade-off, failure case, migration/operations।

## এটা কী (থিওরি)

- বাংলা সারাংশ: `Ambassador` কেবল সংজ্ঞা না; এটি problem-context অনুযায়ী সঠিক guarantee ও architecture boundary বেছে নেওয়ার কৌশল।
- সহজ সংজ্ঞা: Ambassador is a pattern where a helper proxy/process handles outbound connectivity concerns for an application (service discovery, retries, TLS, routing to external services)।
- মেটাফর: একে শহরের ট্রাফিক কন্ট্রোলের মতো ভাবুন, যেখানে সব রাস্তায় একই নিয়ম দিলে জ্যাম হয়; lane-ভিত্তিক নিয়ম দিলে flow স্থিতিশীল হয়।

## কেন দরকার

- সমস্যা সাধারণত load, data, team, আর dependency একসাথে বড় হলে দেখা দেয়।
- business impact: এটি keeps application code simpler এবং standardizes how সার্ভিসগুলো talk to external dependencies।
- এই design না থাকলে short-term patch জমতে জমতে সিস্টেম brittle হয়ে যায়।

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

- সিনিয়র দৃষ্টিতে `Ambassador` কাজ করে clear boundary তৈরির মাধ্যমে: data path, control path, failure path আলাদা করা হয়।
- policy + automation + observability একসাথে না থাকলে design কাগজে ভালো, production-এ দুর্বল।
- trade-off rule: reliability বাড়াতে গেলে cost/complexity বাড়ে; simplicity চাইলে কিছু flexibility কমে।
- production-ready বলতে বোঝায়: measurable SLO, alerting, graceful degradation, এবং tested recovery।

## বাস্তব উদাহরণ

- `Uber`-এর মতো সিস্টেমে একই pattern সব feature-এ একভাবে চলে না; context অনুযায়ী প্রয়োগ বদলায়।
- তাই `Ambassador` implement করার আগে traffic shape, state model, dependency graph, আর blast radius map করা জরুরি।

## ইন্টারভিউ পার্সপেক্টিভ

- interviewer term মুখস্থ শুনতে চায় না; চায় আপনি decision reasoning দেখান।
- ভালো উত্তর কাঠামো: Problem -> Why Now -> Chosen Design -> Trade-off -> Failure Handling -> Metrics।
- red flag avoid করুন: Adding an ambassador ছাড়া observability into প্রক্সি রিট্রাইগুলো/timeouts।
- junior common mistake: শুধু "scale করব" বলা, কিন্তু capacity number, dependency bottleneck, rollback plan না বলা।
- trade-off স্পষ্ট বলুন: performance, cost, reliability, complexity।

## কমন ভুল / ভুল ধারণা

- problem না বুঝে pattern-first architecture করা।
- সব workload-এ একই policy চাপিয়ে দেওয়া।
- failure mode, fallback, runbook না লিখে production-এ যাওয়া।
- "আরেকটা বড় server"-কে long-term strategy ধরে নেওয়া।

## দ্রুত মনে রাখুন

- `Ambassador` বাছাই করবেন requirement-fit দেখে, trend দেখে না।
- বড় server short-term relief দেয়, কিন্তু SPOF আর coordination সমস্যা পুরো সমাধান করে না।
- machine বাড়ালে capacity ও resilience বাড়ে, তবে distributed complexity-ও বাড়ে।
- interview-তে সবসময় বলুন: কখন নেবেন, কখন নেবেন না, ভুল নিলে কী ভাঙবে।
