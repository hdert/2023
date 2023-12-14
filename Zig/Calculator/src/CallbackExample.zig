pub const TestCallbacks = struct {
    const Self = @This();

    callbacks: []const *const fn (f64) f64,

    pub fn init(callbacks: []const *const fn (f64) f64) Self {
        return Self{
            .callbacks = callbacks,
        };
    }

    pub fn run(self: Self, num: f64) f64 {
        var result = num;
        for (self.callbacks) |callback| {
            result = callback(result);
        }
        return result;
    }
};
