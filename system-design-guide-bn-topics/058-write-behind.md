# Write-Behind — বাংলা ব্যাখ্যা

_টপিক নম্বর: 058_

## গল্পে বুঝি

মন্টু মিয়াঁ cache বসিয়েছেন, কিন্তু শুধু cache যোগ করলেই speed/consistency ঠিক থাকে না। data read/write path-এর policy ঠিক না করলে stale data, lost updates, বা origin overload হতে পারে।

`Write-Behind` টপিকটা cache strategy-র নির্দিষ্ট flow বোঝায়: cache miss হলে কী হবে, write করলে cache/DB কোন ক্রমে update হবে, আর freshness কীভাবে রাখা হবে।

প্রতিটি strategy-র সুবিধা আলাদা: latency, durability, write amplification, consistency risk, failure behavior - সব ভিন্ন।

ইন্টারভিউতে strategy বলার সাথে সাথে “cache failure/DB failure হলে কী হবে” ব্যাখ্যা করলে answer বাস্তবসম্মত হয়।

সহজ করে বললে `Write-Behind` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: Write-behind (write-back) updates the ক্যাশ first and writes to the ডাটাবেজ asynchronously later।

বাস্তব উদাহরণ ভাবতে চাইলে `Google`-এর মতো সিস্টেমে `Write-Behind`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Write-Behind` আসলে কীভাবে সাহায্য করে?

`Write-Behind` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- টপিকটি কোন problem solve করে এবং কোন requirement-এ value দেয়—সেটা পরিষ্কার করতে সাহায্য করে।
- behavior, trade-off, limitation, আর user impact একসাথে design answer-এ আনতে সহায়তা করে।
- diagram/term-এর বাইরে operational implication explain করতে সাহায্য করে।
- interview answer-কে context-aware ও defensible করতে কাঠামো দেয়।

---

### কখন `Write-Behind` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → High-write, non-critical, mergeable ডেটা (মেট্রিকস, counters, buffered updates).
- Business value কোথায় বেশি? → এটি উন্নত করে write ল্যাটেন্সি এবং পারে batch writes to কমাতে ডাটাবেজ লোড.
- এই টপিক কোন সমস্যা solve করে - এক লাইনে সেটা কি পরিষ্কার?
- এর core flow/component/assumption কী?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: Financial transactions, orders, অথবা anything requiring durable acknowledgment আগে success.
- ইন্টারভিউ রেড ফ্ল্যাগ: Returning success on রাইট-বিহাইন্ড ছাড়া discussing ডিউরেবিলিটি guarantees.
- Treating রাইট-বিহাইন্ড as safe জন্য critical ডেটা by default.
- কোনো replay অথবা WAL strategy জন্য pending writes.
- Ignoring flush ordering এবং conflict handling.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Write-Behind` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

---

### মন্টুর কেস (ধাপে ধাপে)

- ধাপ ১: read path-এ cache hit/miss flow আঁকুন।
- ধাপ ২: write path-এ DB ও cache update order নির্ধারণ করুন।
- ধাপ ৩: failure case (cache down/DB slow) behavior বলুন।
- ধাপ ৪: TTL/invalidation/refresh policy যোগ করুন।
- ধাপ ৫: duplicate writes/stale reads acceptability mention করুন।

---

### এই টপিকে মন্টু কী সিদ্ধান্ত নিচ্ছে?

- এই টপিক কোন সমস্যা solve করে - এক লাইনে সেটা কি পরিষ্কার?
- এর core flow/component/assumption কী?
- কোন trade-off বা limitation জানালে উত্তর বাস্তবসম্মত হবে?

---

## এক লাইনে

- `Write-Behind` সিস্টেম ডিজাইনের একটি গুরুত্বপূর্ণ ধারণা, যা requirement, behavior, এবং trade-off মিলিয়ে design decision নিতে সাহায্য করে।
- এই টপিকে বারবার আসতে পারে: async persistence, write buffering, durability risk, throughput, flush/retry

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Write-Behind` টপিকটি requirement, behavior, আর trade-off connect করে design decision নেওয়ার ধারণা পরিষ্কার করে।

- রাইট-বিহাইন্ড (write-back) updates the ক্যাশ first এবং writes to the ডাটাবেজ asynchronously later.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: বাস্তব সিস্টেমে scale, cost, correctness, এবং operational complexity সামলাতে এই ধারণা/প্যাটার্ন দরকার হয়।

- এটি উন্নত করে write ল্যাটেন্সি এবং পারে batch writes to কমাতে ডাটাবেজ লোড.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: internals-এর সাথে user-visible behavior, trade-off, এবং operational impact একসাথে ব্যাখ্যা করলে sectionটি শক্তিশালী হয়।

- এই ক্যাশ temporarily becomes the accepted write path, এবং a worker flushes changes to persistent storage.
- এটি পারে boost থ্রুপুট but risks ডেটা loss যদি ক্যাশ/node fails আগে flush unless ডিউরেবিলিটি হলো handled separately.
- Compared সাথে রাইট-থ্রু, রাইট-বিহাইন্ড হলো faster but harder to reason about এবং recover.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Write-Behind` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Google**-scale telemetry অথবা aggregated counters may ব্যবহার buffered/রাইট-বিহাইন্ড patterns যেখানে minor lag হলো acceptable.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Write-Behind` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: High-write, non-critical, mergeable ডেটা (মেট্রিকস, counters, buffered updates).
- কখন ব্যবহার করবেন না: Financial transactions, orders, অথবা anything requiring durable acknowledgment আগে success.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"What happens যদি the ক্যাশ crashes আগে the async flush completes?\"
- রেড ফ্ল্যাগ: Returning success on রাইট-বিহাইন্ড ছাড়া discussing ডিউরেবিলিটি guarantees.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Write-Behind`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Treating রাইট-বিহাইন্ড as safe জন্য critical ডেটা by default.
- কোনো replay অথবা WAL strategy জন্য pending writes.
- Ignoring flush ordering এবং conflict handling.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Returning success on রাইট-বিহাইন্ড ছাড়া discussing ডিউরেবিলিটি guarantees.
- কমন ভুল এড়ান: Treating রাইট-বিহাইন্ড as safe জন্য critical ডেটা by default.
- Data path ও consistency expectation আগে বললে বাকি ডিজাইন explain করা সহজ হয়।
- কেন দরকার (শর্ট নোট): এটি উন্নত করে write ল্যাটেন্সি এবং পারে batch writes to কমাতে ডাটাবেজ লোড.
