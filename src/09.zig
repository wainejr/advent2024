const std = @import("std");

var buffer_file: [32000]i32 = undefined;

fn read_file(file: std.fs.File, nums: []i32) ![]i32 {
    const reader = file.reader();

    var char = try reader.readByte();
    var idx: usize = 0;
    while (char >= '0' and char <= '9') {
        const n: i32 = char - '0';
        nums[idx] = n;
        idx += 1;
        char = reader.readByte() catch {
            break;
        };
    }
    return nums[0..idx];
}

fn get_disk_size(nums: []i32) usize {
    var sum: usize = 0;
    for (nums) |n| {
        sum += @intCast(n);
    }
    return sum;
}

fn populate_disk(nums: []i32, disk: []i32) void {
    var curr_disk_pos: usize = 0;
    for (nums, 0..) |n, idx| {
        // par é arquivo
        if (idx % 2 == 0) {
            const file_id: i32 = @intCast(@divExact(idx, 2));
            for (0..@intCast(n)) |_| {
                disk[curr_disk_pos] = file_id;
                curr_disk_pos += 1;
            }
        } else {
            // impar é espaço vazio
            for (0..@intCast(n)) |_| {
                disk[curr_disk_pos] = -1;
                curr_disk_pos += 1;
            }
        }
    }
}

fn move_files_disk(disk: []i32) void {
    var idx_end: usize = disk.len - 1;
    var idx_start: usize = 0;

    while (idx_start < idx_end) {
        while (disk[idx_start] >= 0 and idx_start < idx_end) {
            idx_start += 1;
        }
        while (disk[idx_end] < 0 and idx_start < idx_end) {
            idx_end -= 1;
        }
        if (idx_start >= idx_end) {
            break;
        }
        disk[idx_start] = disk[idx_end];
        disk[idx_end] = -1;
        idx_start += 1;
        idx_end -= 1;
    }

    std.debug.print("disk moved in {any}\n", .{disk});
}

pub fn main() !void {
    const filename = "src/input/09.txt";

    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const nums = try read_file(file, @ptrCast(&buffer_file));
    std.debug.print("nums {any}\n", .{nums});
    const disk_size = get_disk_size(nums);
    std.debug.print("disk_size {any}\n", .{disk_size});

    var disk = try allocator.alloc(i32, disk_size);
    populate_disk(nums, disk[0..]);
    std.debug.print("disk {any}\n", .{disk});
    move_files_disk(disk);
    std.debug.print("disk moved {any}\n", .{disk});

    var hashsum: usize = 0;
    for (disk, 0..) |d, idx| {
        if (d > 0) {
            hashsum += @as(usize, @intCast(d)) * idx;
        }
    }

    std.debug.print("hashsum {}\n", .{hashsum});
}
