// Ops for SChar

        PREDICATE_OVERRIDE_TRUE(isChar, charp)

        OP2_CHAIN(char_lt)
        OP2_CHAIN(char_le)
        OP2_CHAIN(char_gt)
        OP2_CHAIN(char_ge)
        OP2_CHAIN(char_equals)
        OP2_OVERRIDE_REVERSED(char_lt, SChar) {
            return (arg1.val < this.val) ? Factory.True : Factory.False;
        }
        OP2_OVERRIDE_REVERSED(char_le, SChar) {
            return (arg1.val <= this.val) ? Factory.True : Factory.False;
        }
        OP2_OVERRIDE_REVERSED(char_gt, SChar) {
            return (arg1.val > this.val) ? Factory.True : Factory.False;
        }
        OP2_OVERRIDE_REVERSED(char_ge, SChar) {
            return (arg1.val >= this.val) ? Factory.True : Factory.False;
        }
        OP2_OVERRIDE_REVERSED(char_equals, SChar) {
            return (arg1.val == this.val) ? Factory.True : Factory.False;
        }

        OP1_OVERRIDE(char2integer) {
            return Factory.makeNumber (this.val);
        }

        OP2_OVERRIDE_REVERSED(make_string, SFixnum) {
            return Factory.makeString(arg1.value, this.val);
        }

        // Special Operations
        SPECIALOP2_OVERRIDE_REVERSED_CASE(eqvp_not_eq, char, SChar) {
            Reg.Result = (arg1.val == this.val) ? Factory.True : Factory.False;
        }