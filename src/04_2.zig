const std = @import("std");

const State = enum { None, MUL, op, check_do };
const StateDo = enum { Doing, NotDoing };
const RetType = struct {
    char: u8,
    val: i32,
};

const Pos = struct { x: i32, y: i32 };

const IdxStruct = struct {
    const Self = @This();
    NX: usize,
    NY: usize,

    pub fn init(n_rows: usize, n_cols: usize) Self {
        return .{ .NX = n_rows, .NY = n_cols };
    }

    pub fn idx2pos(self: Self, idx: usize) Pos {
        const x: i32 = @intCast(@mod(idx, self.NY));
        const y: i32 = @intCast(@divFloor(idx, self.NY));
        return .{ .x = x, .y = y };
    }

    pub fn pos2idx(self: Self, pos: Pos) usize {
        return @intCast(@as(usize, @intCast(pos.x)) + @as(usize, @intCast(pos.y)) * self.NY);
    }

    pub fn is_valid(self: Self, pos: Pos) bool {
        return pos.y >= 0 and pos.y < self.NX and pos.x >= 0 and pos.x < self.NY;
    }
};

fn get_line_size(file: std.fs.File) !usize {
    try file.seekTo(0);
    const offset = try file.getPos();
    const reader = file.reader();
    var buff: [1000]u8 = undefined;

    _ = try reader.readUntilDelimiter(&buff, '\n');
    const pos = try file.getPos();
    try file.seekTo(0);

    return pos - offset;
}

fn get_n_lines(file: std.fs.File) !usize {
    try file.seekTo(0);

    var n_new_lines: usize = 0;
    const reader = file.reader();

    while (true) {
        const char = reader.readByte() catch {
            break;
        };
        if (char == '\n') {
            n_new_lines += 1;
        }
    }
    try file.seekTo(0);
    return n_new_lines;
}

fn populate_array(file: std.fs.File, arr: *[]u8) !void {
    try file.seekTo(0);

    const reader = file.reader();
    var idx: usize = 0;
    while (true) {
        const char = reader.readByte() catch {
            break;
        };
        // std.debug.print("{c}\n", .{char});
        if (char != '\n') {
            arr.*[idx] = char;
            idx += 1;
        }
    }
    try file.seekTo(0);
}

pub fn main() !void {
    const filename = "src/input/04.txt";

    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    const line_size = try get_line_size(file);
    const n_lines = try get_n_lines(file);

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    var map_array: []u8 = try allocator.alloc(u8, n_lines * line_size);

    try populate_array(file, &map_array);

    std.debug.print("{any}\n", .{map_array});

    const idx_calc = IdxStruct.init(line_size, n_lines);

    const directions: [2][2]i32 = .{
        .{ 1, 1 },
        .{ 1, -1 },
    };
    var n_mas: usize = 0;

    for (0..n_lines * line_size) |idx| {
        const pos = idx_calc.idx2pos(idx);
        if (map_array[idx] != 'A') {
            continue;
        }

        var is_mas = true;
        for (directions) |dir| {
            const pos_m: Pos = .{
                .x = pos.x + dir[0] * -1,
                .y = pos.y + dir[1] * -1,
            };
            const pos_p: Pos = .{
                .x = pos.x + dir[0] * 1,
                .y = pos.y + dir[1] * 1,
            };
            if (!idx_calc.is_valid(pos_m) or !idx_calc.is_valid(pos_p)) {
                is_mas = false;
                break;
            }
            const c1 = map_array[idx_calc.pos2idx(pos_m)];
            const c2 = map_array[idx_calc.pos2idx(pos_p)];
            if ((c1 == 'M' and c2 == 'S') or (c1 == 'S' and c2 == 'M')) {
                continue;
            } else {
                is_mas = false;
                break;
            }
        }
        if (is_mas) {
            std.debug.print("pos {any} is mas at {any}\n", .{ pos, pos });
            n_mas += 1;
        }
    }
    std.debug.print("n mas {}\n", .{n_mas});
}
