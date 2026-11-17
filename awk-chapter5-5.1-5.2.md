# The AWK Programming Language, 2nd Edition

Programs and data files for Chapter 5, Sections 5.1 through 5.2.

Extracted from `programs.tar`; source reproduced as-is.

---

## `prep1`

```awk
# prep1 - prepare countries by continent and pop density

BEGIN { FS = "\t" }

      { printf("%s,%s,%d,%d,%.1f\n",
            $4, $1, $3, $2, 1000*$3/$2) | "sort -t, -k1,1 -k5rn"
      }
```

---

## `form1`

```awk
# form1 - format countries data by continent, pop density

BEGIN { FS = ","
        printf("%-15s %-10s %10s %7s %12s\n\n",
            "CONTINENT", "COUNTRY", "POPULATION",
            "AREA", "POP. DEN.")
      }
      { printf("%-15s %-10s %7d %10d %10.1f\n",
            $1, $2, $3, $4, $5)
      }
```

---

## `prep2`

```awk
# prep2 - prepare countries by continent, inverse pop density

BEGIN { FS = "\t" }
      { den = 1000*$3/$2
        printf("%-15s,%12.8f,%s,%d,%d,%.1f\n",
            $4, 1/den, $1, $3, $2, den) | "sort"
      }
```

---

## `form2`

```awk
# form2 - format countries by continent, pop density

BEGIN { FS = ","
        printf("%-15s %-10s %10s %7s %12s\n",
            "CONTINENT", "COUNTRY", "POPULATION",
            "AREA", "POP. DEN.")
      }
      { if ($1 != prev) {
            print ""
            prev = $1
        } else {
            $1 = ""
        }
        printf("%-15s %-10s %7d %10d %10.1f\n",
            $1, $2, $3, $4, $5)
      }
```

---

## `form2a`

```awk
# form2a - format countries by continent, pop density

BEGIN { FS = ","
        printf("%-15s %-10s %10s %7s %12s\n",
            "CONTINENT", "COUNTRY", "POPULATION",
            "AREA", "POP. DEN.")
      }
{ cont[NR] = $1; country[NR] = $2; pop[NR] = $3
  area[NR] = $4; den[NR] = $5
}
END {
  for (i = 1; i <= NR; i++) {
    if (cont[i] != cont[i-1])
      print ""
    c = cont[i] == cont[i-1] ? "" : cont[i]
    printf("%-15s %-10s %7d %10d %10.1f\n",
            c, country[i], pop[i], area[i], den[i])
  }
}
```

---

## `header`

```text
COUNTRY	AREA	POPULATION	CONTINENT
```

---

## `info`

```sh
awk -v country=$1 '
# info - print information about country
#    usage: info country-name

BEGIN { FS = "\t" }

$1 ~ country {
    printf("%s:\n", $1)
    printf("\t%d million people\n", $3)
    printf("\t%.3f million sq. km.\n", $2/1000)
    printf("\t%.1f people per sq. km.\n", 1000*$3/$2)
}
' countries
```

---

## `letter.txt`

```text
Subject: Demographic Information About #1
From: AWK Demographics, Inc.

In response to your request for information about #1,
our latest research has revealed that its population is #2
million people and its area is #3 million square kilometers.
This gives #1 a population density of #4 people per
square kilometer.
```

---

## `form.gen`

```awk
# form.gen - generate form letters
#   input:  prototype file letter.txt; data lines
#   output: one form letter per data line

BEGIN {
    FS = ","
    while (getline <"letter.txt" > 0) # read form letter
        form[++n] = $0
}

{   for (i = 1; i <= n; i++) { # read data lines
        temp = form[i]         # each line generates a letter
        for (j = 1; j <= NF; j++)
            gsub("#" j, $j, temp)
        print temp
    }
}
```
