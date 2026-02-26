# Compensating Transaction — বাংলা ব্যাখ্যা

_টপিক নম্বর: 150_

## গল্পে বুঝি

মন্টু মিয়াঁ `Compensating Transaction`-এর মতো resiliency pattern শেখেন কারণ distributed system-এ failure normal, exception না।

`Compensating Transaction` টপিকটা failure handle করার একটি নির্দিষ্ট কৌশল দেয় - সব failure-এ blind retry করলে অনেক সময় সমস্যা বাড়ে।

এই ধরনের pattern-এ context খুব গুরুত্বপূর্ণ: retryable vs non-retryable error, timeout budget, partial side effects, downstream overload, user experience।

ইন্টারভিউতে pattern নামের সাথে “কখন ব্যবহার করব না” বললে উত্তর অনেক শক্তিশালী হয়।

সহজ করে বললে `Compensating Transaction` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: A compensating transaction is a workflow step that semantically undoes or offsets prior actions when part of a distributed process fails।

বাস্তব উদাহরণ ভাবতে চাইলে `Amazon`-এর মতো সিস্টেমে `Compensating Transaction`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Compensating Transaction` আসলে কীভাবে সাহায্য করে?

`Compensating Transaction` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- failure scenario ধরে detection, isolation, recovery, আর fallback behavior design করতে সাহায্য করে।
- redundancy থাকলেই reliability solved না—এই operational reality স্পষ্ট করে।
- failover, retry, throttling, circuit breaking, degradation mode—কখন কোনটা ব্যবহার করবেন তা বোঝায়।
- RTO/RPO-like thinking, uptime target, আর cost trade-off discuss করতে সহায়তা করে।

---

### কখন `Compensating Transaction` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → Distributed workflows, sagas, multi-সার্ভিস business transactions.
- Business value কোথায় বেশি? → Multi-সার্ভিস workflows অনেক সময় পারে না ব্যবহার one ACID transaction জুড়ে all সিস্টেমগুলো.
- failure domain কী: instance, AZ, region, dependency, deployment?
- failure detect করার signal কী, এবং automatic reaction কী হবে?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: Single-ডাটাবেজ transactional operations যা পারে ব্যবহার normal ACID transactions directly.
- ইন্টারভিউ রেড ফ্ল্যাগ: Assuming distributed transactions জুড়ে all সার্ভিসগুলো হলো সবসময় practical.
- Compensation steps যা হলো না আইডেমপোটেন্ট.
- কোনো persistent workflow স্টেট to know what to compensate.
- Treating compensation as guaranteed exact reversal in all domains.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Compensating Transaction` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

---

### মন্টুর কেস (ধাপে ধাপে)

- ধাপ ১: failure type classify করুন।
- ধাপ ২: pattern trigger condition ঠিক করুন।
- ধাপ ৩: state/side-effect safety (idempotency/compensation) নিশ্চিত করুন।
- ধাপ ৪: metrics/alerts দিয়ে behavior observe করুন।
- ধাপ ৫: misconfiguration হলে কী regression হবে তা বলুন।

---

### এই টপিকে মন্টু কী সিদ্ধান্ত নিচ্ছে?

- failure domain কী: instance, AZ, region, dependency, deployment?
- failure detect করার signal কী, এবং automatic reaction কী হবে?
- degrade mode, failover, retry, throttling - কোনটা কখন চালু হবে?

---

## এক লাইনে

- `Compensating Transaction` failure হলেও service continuity, recovery/failover behavior, এবং resilience trade-off design-এর টপিক।
- এই টপিকে বারবার আসতে পারে: compensating, transaction, use case, trade-off, failure case

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Compensating Transaction` failure handling, service continuity, failover/recovery behavior, এবং resilience design-এর মূল ধারণা বোঝায়।

- একটি compensating transaction হলো a workflow step যা semantically undoes অথবা offsets prior actions যখন part of a distributed process fails.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: Failure normal ঘটনা; outage impact কমাতে আগেই detection, isolation, recovery, এবং fallback strategy দরকার।

- Multi-সার্ভিস workflows অনেক সময় পারে না ব্যবহার one ACID transaction জুড়ে all সিস্টেমগুলো.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: failure mode, detection signal, automatic reaction, degraded mode, এবং recovery trade-off একসাথে ব্যাখ্যা করলে senior insight বোঝায়।

- Each step commits locally; যদি a later step fails, compensating actions reverse অথবা offset earlier steps (refund, release inventory, cancel reservation).
- Compensation must হতে আইডেমপোটেন্ট এবং aware যা true rollback may হতে impossible, so the goal হলো business কনসিসটেন্সি.
- Compare সাথে ডাটাবেজ rollback: compensation হলো application-level recovery, না a storage-engine transaction undo.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Compensating Transaction` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Amazon** order workflow may need to release inventory এবং refund payment যদি shipment creation fails later in the process.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Compensating Transaction` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: Distributed workflows, sagas, multi-সার্ভিস business transactions.
- কখন ব্যবহার করবেন না: Single-ডাটাবেজ transactional operations যা পারে ব্যবহার normal ACID transactions directly.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"What compensating actions হলো needed in আপনার checkout/booking flow?\"
- রেড ফ্ল্যাগ: Assuming distributed transactions জুড়ে all সার্ভিসগুলো হলো সবসময় practical.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Compensating Transaction`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Compensation steps যা হলো না আইডেমপোটেন্ট.
- কোনো persistent workflow স্টেট to know what to compensate.
- Treating compensation as guaranteed exact reversal in all domains.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Assuming distributed transactions জুড়ে all সার্ভিসগুলো হলো সবসময় practical.
- কমন ভুল এড়ান: Compensation steps যা হলো না আইডেমপোটেন্ট.
- Consistency টপিকে endpoint-by-endpoint guarantee (read-after-write, eventual, strong) বললে উত্তর অনেক পরিষ্কার হয়।
- কেন দরকার (শর্ট নোট): Multi-সার্ভিস workflows অনেক সময় পারে না ব্যবহার one ACID transaction জুড়ে all সিস্টেমগুলো.
