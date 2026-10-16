namespace MnTechFixture {
    public static class Decoder {
        public static int Transform(int value) { return value * 2 + 7; }
        public static bool IsEnabled(byte flags) { return (flags & 1) != 0; }
        public static int Combine(int value) { return Transform(value) + 3; }
    }
}
