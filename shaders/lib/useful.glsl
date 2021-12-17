bool isOverworld() {
	#ifdef END
		return false;
	#endif
	#ifdef NETHER
		return false;
	#endif
    return true;
}