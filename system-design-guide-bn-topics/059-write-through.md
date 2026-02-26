# Write-Through — বাংলা ব্যাখ্যা

_টপিক নম্বর: 059_

## গল্পে বুঝি

মন্টু মিয়াঁ cache বসিয়েছেন, কিন্তু শুধু cache যোগ করলেই speed/consistency ঠিক থাকে না। data read/write path-এর policy ঠিক না করলে stale data, lost updates, বা origin overload হতে পারে।

`Write-Through` টপিকটা cache strategy-র নির্দিষ্ট flow বোঝায়: cache miss হলে কী হবে, write করলে cache/DB কোন ক্রমে update হবে, আর freshness কীভাবে রাখা হবে।

প্রতিটি strategy-র সুবিধা আলাদা: latency, durability, write amplification, consistency risk, failure behavior - সব ভিন্ন।

ইন্টারভিউতে strategy বলার সাথে সাথে “cache failure/DB failure হলে কী হবে” ব্যাখ্যা করলে answer বাস্তবসম্মত হয়।

সহজ করে বললে `Write-Through` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: Write-through writes data to the ক্যাশ and the backing store in the same request path।

বাস্তব উদাহরণ ভাবতে চাইলে `Amazon`-এর মতো সিস্টেমে `Write-Through`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Write-Through` আসলে কীভাবে সাহায্য করে?

`Write-Through` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- টপিকটি কোন problem solve করে এবং কোন requirement-এ value দেয়—সেটা পরিষ্কার করতে সাহায্য করে।
- behavior, trade-off, limitation, আর user impact একসাথে design answer-এ আনতে সহায়তা করে।
- diagram/term-এর বাইরে operational implication explain করতে সাহায্য করে।
- interview answer-কে context-aware ও defensible করতে কাঠামো দেয়।

---

### কখন `Write-Through` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → Read-heavy ডেটা সাথে frequent read-পরে-write access.
- Business value কোথায় বেশি? → এটি keeps ক্যাশ এবং ডাটাবেজ more synchronized যখন/একইসাথে still serving future reads from ক্যাশ.
- এই টপিক কোন সমস্যা solve করে - এক লাইনে সেটা কি পরিষ্কার?
- এর core flow/component/assumption কী?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: Write-heavy workloads সাথে many values rarely read again.
- ইন্টারভিউ রেড ফ্ল্যাগ: Assuming রাইট-থ্রু eliminates all staleness issues automatically.
- Ignoring ক্যাশ eviction right পরে writes.
- না defining রিট্রাই/compensation on partial write ফেইলিউরগুলো.
- ব্যবহার করে রাইট-থ্রু on every dataset ছাড়া hit-rate analysis.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Write-Through` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

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

- `Write-Through` সিস্টেম ডিজাইনের একটি গুরুত্বপূর্ণ ধারণা, যা requirement, behavior, এবং trade-off মিলিয়ে design decision নিতে সাহায্য করে।
- এই টপিকে বারবার আসতে পারে: write path cache+DB, consistency, write latency, cache population, failure behavior

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Write-Through` টপিকটি requirement, behavior, আর trade-off connect করে design decision নেওয়ার ধারণা পরিষ্কার করে।

- রাইট-থ্রু writes ডেটা to the ক্যাশ এবং the backing store in the same রিকোয়েস্ট path.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: বাস্তব সিস্টেমে scale, cost, correctness, এবং operational complexity সামলাতে এই ধারণা/প্যাটার্ন দরকার হয়।

- এটি keeps ক্যাশ এবং ডাটাবেজ more synchronized যখন/একইসাথে still serving future reads from ক্যাশ.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: internals-এর সাথে user-visible behavior, trade-off, এবং operational impact একসাথে ব্যাখ্যা করলে sectionটি শক্তিশালী হয়।

- এই write হলো acknowledged শুধু পরে the backing store write succeeds (এবং অনেক সময় ক্যাশ update succeeds too).
- এটি simplifies কনসিসটেন্সি compared সাথে রাইট-বিহাইন্ড but adds write ল্যাটেন্সি এবং may duplicate write ট্রাফিক.
- Compared সাথে ক্যাশ-অ্যাসাইড, রাইট-থ্রু keeps ক্যাশ warmer পরে writes but পারে waste ক্যাশ space on never-read values.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Write-Through` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Amazon** may ব্যবহার রাইট-থ্রু জন্য frequently read ইউজার/session preferences যেখানে read-পরে-write freshness matters.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Write-Through` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: Read-heavy ডেটা সাথে frequent read-পরে-write access.
- কখন ব্যবহার করবেন না: Write-heavy workloads সাথে many values rarely read again.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"How do আপনি handle partial ফেইলিউর যদি DB write succeeds but ক্যাশ update fails?\"
- রেড ফ্ল্যাগ: Assuming রাইট-থ্রু eliminates all staleness issues automatically.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Write-Through`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Ignoring ক্যাশ eviction right পরে writes.
- না defining রিট্রাই/compensation on partial write ফেইলিউরগুলো.
- ব্যবহার করে রাইট-থ্রু on every dataset ছাড়া hit-rate analysis.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Assuming রাইট-থ্রু eliminates all staleness issues automatically.
- কমন ভুল এড়ান: Ignoring ক্যাশ eviction right পরে writes.
- Data path ও consistency expectation আগে বললে বাকি ডিজাইন explain করা সহজ হয়।
- কেন দরকার (শর্ট নোট): এটি keeps ক্যাশ এবং ডাটাবেজ more synchronized যখন/একইসাথে still serving future reads from ক্যাশ.
