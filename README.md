# Transliteration PowerShell Module (Russian-English)

## Transliteration Standards:
- `BGN/PCGN 1947 System`
- `GOST R 52535.1-2006`

## Example of use:
```
ConvertTo-Translit -String "Бендер Остап Ибрагимович" -Standard bgn-pcgn-1947
>> Bender Ostap Ibragimovich

ConvertTo-Translit -String "Остап Сулейман Берта Мария Бендер бей" -Format Uppercase
>> OSTAP SULEYMAN BERTA MARIYA BENDER BEY

ConvertTo-Translit -String "Ипполит Матвеевич Воробьянинов" -Standard gost-r-52535.1-2006 -Format Lowercase
>> ippolit matveevich vorobianinov

ConvertTo-Translit -String "Архипьева Глафирья Геннадьевна" -Standard bgn-pcgn-1947 -Format Capitalize
>> Arkhipyeva Glafirya Gennadyevna
```