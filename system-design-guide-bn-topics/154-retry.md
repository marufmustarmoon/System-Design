# Retry — বাংলা ব্যাখ্যা

_টপিক নম্বর: 154_

## গল্পে বুঝি

মন্টু মিয়াঁ `Retry`-এর মতো resiliency pattern শেখেন কারণ distributed system-এ failure normal, exception না।

`Retry` টপিকটা failure handle করার একটি নির্দিষ্ট কৌশল দেয় - সব failure-এ blind retry করলে অনেক সময় সমস্যা বাড়ে।

এই ধরনের pattern-এ context খুব গুরুত্বপূর্ণ: retryable vs non-retryable error, timeout budget, partial side effects, downstream overload, user experience।

ইন্টারভিউতে pattern নামের সাথে “কখন ব্যবহার করব না” বললে উত্তর অনেক শক্তিশালী হয়।

সহজ করে বললে `Retry` টপিকটি নিয়ে সোর্স নোটের মূল কথাটা হলো: Retry is a pattern where failed operations are attempted again after a delay, usually for transient faults।

বাস্তব উদাহরণ ভাবতে চাইলে `Amazon`-এর মতো সিস্টেমে `Retry`-এর trade-off খুব স্পষ্ট দেখা যায়।

---

### `Retry` আসলে কীভাবে সাহায্য করে?

`Retry` ব্যবহার করার আসল মূল্য হলো requirement, behavior, এবং trade-off-কে একইসাথে পরিষ্কার করে design decision নেওয়া।

- transient failure হলে success rate বাড়াতে controlled retry policy design করতে সাহায্য করে।
- exponential backoff, jitter, retry budget না দিলে retry storm কেন হয় তা বোঝায়।
- retryable vs non-retryable error classification পরিষ্কার করতে সাহায্য করে।
- upstream/downstream overload পরিস্থিতিতে safer failure handling plan করতে সহায়তা করে।

---

### কখন `Retry` বেছে নেওয়া সঠিক?

মন্টু নিজের কাছে কয়েকটা প্রশ্ন করে:

- কোথায়/কখন use করবেন? → Transient network ফেইলিউরগুলো, rate-limited APIs (সাথে backoff), কিউ processing.
- Business value কোথায় বেশি? → Networks এবং সার্ভিসগুলো fail transiently; a later attempt অনেক সময় succeeds ছাড়া human intervention.
- failure domain কী: instance, AZ, region, dependency, deployment?
- failure detect করার signal কী, এবং automatic reaction কী হবে?

এই প্রশ্নগুলোর উত্তরে topicটা product requirement-এর সাথে fit করলে সেটাই সঠিক choice।

---

### কিন্তু কোথায় বিপদ?

এই টপিক ভুলভাবে ব্যবহার করলে সাধারণত এই সমস্যা দেখা দেয়:

- ভুল context: Permanent errors (bad রিকোয়েস্টগুলো) অথবা non-আইডেমপোটেন্ট operations ছাড়া protection.
- ইন্টারভিউ রেড ফ্ল্যাগ: Immediate fixed-interval রিট্রাইগুলো জন্য all errors.
- Retrying validation/auth errors.
- কোনো jitter causing রিট্রাই synchronization.
- Retrying at multiple layers ছাড়া a রিট্রাই budget.

তাই মন্টু এক জিনিস পরিষ্কার রাখে:

> `Retry` শুধু term না; context + trade-off + user impact একসাথে define না করলে design answer অসম্পূর্ণ।

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

- `Retry` transient failure হলে controlled retry (backoff/jitter/budget সহ) ব্যবহার করে success rate বাড়ানোর resiliency pattern।
- এই টপিকে বারবার আসতে পারে: exponential backoff, jitter, retry budget, transient failure, retry storm

## এটা কী (থিওরি)

সহজ ভাষায় সংজ্ঞা ও মূল ধারণা:

- বাংলা সারাংশ: `Retry` failure handling, service continuity, failover/recovery behavior, এবং resilience design-এর মূল ধারণা বোঝায়।

- রিট্রাই হলো a pattern যেখানে failed operations হলো attempted again পরে a delay, usually জন্য transient faults.

## কেন দরকার

কেন এই ধারণা/প্যাটার্ন দরকার হয়:

- বাংলা সারাংশ: Failure normal ঘটনা; outage impact কমাতে আগেই detection, isolation, recovery, এবং fallback strategy দরকার।

- Networks এবং সার্ভিসগুলো fail transiently; a later attempt অনেক সময় succeeds ছাড়া human intervention.

## কীভাবে কাজ করে (সিনিয়র-লেভেল ইনসাইট)

বাস্তবে/প্রোডাকশনে সাধারণত এভাবে কাজ করে:

- বাংলা সারাংশ: failure mode, detection signal, automatic reaction, degraded mode, এবং recovery trade-off একসাথে ব্যাখ্যা করলে senior insight বোঝায়।

- Safe রিট্রাইগুলো require timeouts, idempotency, exponential backoff, jitter, এবং রিট্রাই budgets.
- রিট্রাই policy should হতে selective by error type (timeout vs validation error) এবং bounded to এড়াতে storms.
- Compare সাথে সার্কিট ব্রেকার: রিট্রাইগুলো attempt recovery; সার্কিট ব্রেকারs রোধ করতে overload যখন ফেইলিউরগুলো persist.

## বাস্তব উদাহরণ

একটি পরিচিত প্রোডাক্ট/সিস্টেমের উদাহরণ:

- বাংলা সারাংশ: বাস্তব উদাহরণে খেয়াল করুন, `Retry` একই product-এর ভিন্ন feature/path-এ ভিন্নভাবে apply হতে পারে; context-টাই আসল।

- **Amazon** সার্ভিস ক্লায়েন্টগুলো অনেক সময় রিট্রাই transient dependency errors সাথে backoff এবং jitter যখন/একইসাথে ব্যবহার করে idempotency keys জন্য writes.

## ইন্টারভিউ পার্সপেক্টিভ

ইন্টারভিউতে উত্তর দেওয়ার সময় যেসব দিক বললে ভালো হয়:

- বাংলা সারাংশ: ইন্টারভিউতে `Retry` explain করার সময় scope, user impact, trade-off, failure case, আর “কখন ব্যবহার করবেন না” — এই পাঁচটি দিক বললে উত্তর শক্তিশালী হয়।

- কখন ব্যবহার করবেন: Transient network ফেইলিউরগুলো, rate-limited APIs (সাথে backoff), কিউ processing.
- কখন ব্যবহার করবেন না: Permanent errors (bad রিকোয়েস্টগুলো) অথবা non-আইডেমপোটেন্ট operations ছাড়া protection.
- একটা কমন ইন্টারভিউ প্রশ্ন: \"What রিট্রাই policy would আপনি ব্যবহার জন্য এটি dependency এবং why?\"
- রেড ফ্ল্যাগ: Immediate fixed-interval রিট্রাইগুলো জন্য all errors.

## কমন ভুল / ভুল ধারণা

যে ভুলগুলো অনেকেই করে:

- বাংলা সারাংশ: `Retry`-এ সাধারণ ভুল হলো শুধু term/definition বলা; context, limitation, operational cost, এবং user-visible impact না বলা।

- Retrying validation/auth errors.
- কোনো jitter causing রিট্রাই synchronization.
- Retrying at multiple layers ছাড়া a রিট্রাই budget.

## দ্রুত মনে রাখুন

- রেড ফ্ল্যাগ মনে রাখুন: Immediate fixed-interval রিট্রাইগুলো জন্য all errors.
- কমন ভুল এড়ান: Retrying validation/auth errors.
- ইন্টারভিউতে কখন ব্যবহার করবেন/করবেন না - দুইটাই বললে উত্তরের মান বাড়ে।
- কেন দরকার (শর্ট নোট): Networks এবং সার্ভিসগুলো fail transiently; a later attempt অনেক সময় succeeds ছাড়া human intervention.
