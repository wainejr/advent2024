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

const SpaceFree = struct { found: bool, idx_start: usize };

fn find_leftmost_free_space(disk: []i32, size: usize, max_pos: usize) SpaceFree {
    var n_found: usize = 0;
    var idx_start: usize = 0;

    for (0..max_pos) |idx| {
        const d = disk[idx];
        if (d < 0) {
            if (n_found == 0) {
                idx_start = idx;
            }
            n_found += 1;
        } else {
            n_found = 0;
        }
        if (n_found == size) {
            return SpaceFree{ .found = true, .idx_start = idx_start };
        }
    }
    return SpaceFree{ .found = false, .idx_start = 0 };
}

fn move_files_disk(disk: []i32) void {
    var idx_file: i32 = undefined;
    for (0..disk.len) |idx| {
        const rev_idx = disk.len - 1 - idx;
        if (disk[rev_idx] > 0) {
            idx_file = disk[rev_idx];
            break;
        }
    }
    var found: bool = false;
    var size_file: usize = 0;
    var curr_idx: usize = disk.len - 1;

    while (curr_idx > 0) {
        const d = disk[curr_idx];
        if (d != idx_file and size_file > 0) {
            const space = find_leftmost_free_space(disk, size_file, curr_idx + 1);
            std.debug.print("trying to move file {} size {} res {} curr_idx {}\n", .{ idx_file, size_file, space, curr_idx });
            if (space.found) {
                const start = space.idx_start;
                for (start..start + size_file) |i| {
                    disk[i] = idx_file;
                }
                for (curr_idx + 1..curr_idx + 1 + size_file) |i| {
                    disk[i] = -1;
                }
            }
            idx_file -= 1;
            found = false;
        }

        if (d == idx_file) {
            if (!found) {
                size_file = 0;
            }
            found = true;
            size_file += 1;
        } else {
            found = false;
            size_file = 0;
        }

        curr_idx -= 1;
    }
}

pub fn main() !void {
    const filename = "src/input/09.txt";

    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const nums = try read_file(file, @ptrCast(&buffer_file));
    // std.debug.print("nums {any}\n", .{nums});
    const disk_size = get_disk_size(nums);
    // std.debug.print("disk_size {any}\n", .{disk_size});

    var disk = try allocator.alloc(i32, disk_size);
    populate_disk(nums, disk[0..]);
    // std.debug.print("disk {any}\n", .{disk});
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
