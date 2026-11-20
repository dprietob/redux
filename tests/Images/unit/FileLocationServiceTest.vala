using Redux.Images;

namespace Redux.Tests {

    public void register_file_location_service_tests()
    {
        Test.add_func("/images/location/shortens-home-folder", () => {
            var service = new FileLocationService();
            var inside_home = File.new_for_path(Path.build_filename(Environment.get_home_dir(), "Pictures", "a.png"));
            assert_cmpstr(service.display_path(inside_home), CompareOperator.EQ, "~/Pictures/a.png");
            assert_cmpstr(service.display_path(File.new_for_path("/media/disk/a.png")), CompareOperator.EQ,
            "/media/disk/a.png");
        });

        Test.add_func("/images/location/prefers-portal-host-path", () => {
            var service = new FileLocationService();
            var info = new FileInfo();
            info.set_attribute_string(FileLocationService.HOST_PATH_ATTRIBUTE,
            Path.build_filename(Environment.get_home_dir(), "Descargas", "fotos"));
            var portal_file = File.new_for_path("/run/user/1000/doc/ABC123/fotos");
            assert_cmpstr(service.display_path_from_info(portal_file, info), CompareOperator.EQ, "~/Descargas/fotos");
        });
    }
}
